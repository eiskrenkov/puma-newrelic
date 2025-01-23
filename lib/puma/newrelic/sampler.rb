require "newrelic_rpm"

module Puma
  module NewRelic
    class Sampler
      def initialize(launcher)
        config = ::NewRelic::Agent.config[:puma] || {}
        @launcher = launcher
        @sample_rate = config.fetch("sample_rate", 23)
        @keys = config.fetch("keys", %i[backlog running pool_capacity max_threads requests_count]).map(&:to_sym)
        @last_sample_at = Time.now
      end

      def collect
        @running = true
        while @running
          sleep 1
          begin
            if should_sample?
              @last_sample_at = Time.now
              puma_stats = @launcher.stats
              record_metrics(puma_stats)
            end
          rescue Exception => e # rubocop:disable Lint/RescueException
            ::NewRelic::Agent.logger.error(e.message)
          end
        end
      end

      def should_sample?
        Time.now - @last_sample_at > @sample_rate
      end

      def stop
        @running = false
      end

      def record_metrics(stats)
        metrics = Hash.new { |h, k| h[k] = 0 }

        if stats[:worker_status] # Cluster mode
          metrics[:workers_count] = stats[:workers]
          stats[:worker_status].each do |worker|
            worker[:last_status].each { |key, value| metrics[key] += value if @keys.include?(key) }
          end
        else # Single mode
          metrics[:workers_count] = 1
          stats.each { |key, value| metrics[key] += value if @keys.include?(key) }
        end

        metrics.each do |key, value|
          ::NewRelic::Agent.logger.debug("Recorded metric: Custom/Puma/#{key}=#{value}")
          ::NewRelic::Agent.record_metric("Custom/Puma/#{key}", value)
        end
      end
    end
  end
end
