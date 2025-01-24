require "newrelic_rpm"

module Puma
  module NewRelic
    class Sampler
      def initialize(launcher)
        ::NewRelic::Agent.manual_start
        config = ::NewRelic::Agent.config[:puma] || {}
        @launcher = launcher
        @sample_interval = config.fetch("sample_interval", 23)
        @keys = config.fetch("keys", %i[backlog running pool_capacity max_threads requests_count]).map(&:to_sym)
        @last_sample_at = Time.now
        @launcher.log_writer.log("NewRelic Sampler started with interval #{@sample_interval} seconds")
      end

      def collect
        @running = true
        while @running
          sleep 1
          record_metrics(@launcher.stats) if should_sample?
        end
      end

      def should_sample?
        Time.now - @last_sample_at > @sample_interval
      end

      def stop
        @running = false
      end

      def record_metrics(stats)
        @launcher.log_writer.log("NewRelic Sampler collecting metrics")
        @last_sample_at = Time.now
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
          ::NewRelic::Agent.logger.info("Record metric: Custom/Puma/#{key}=#{value}")
          ::NewRelic::Agent.record_metric("Custom/Puma/#{key}", value)
        end
      end
    end
  end
end
