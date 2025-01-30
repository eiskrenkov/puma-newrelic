require "newrelic_rpm"

module Puma
  module NewRelic
    class Sampler
      METRICS = %i[backlog running pool_capacity max_threads].freeze

      attr_reader :launcher, :sampling_interval

      def initialize(launcher)
        ::NewRelic::Agent.manual_start

        @launcher = launcher
        @sampling_interval = ENV["PUMA_STATS_SAMPLING_INTERVAL"]&.to_i
      end

      def enabled?
        !sampling_interval.nil?
      end

      def collect
        log("NewRelic Sampler started with interval #{sampling_interval} seconds")

        @running = true
        @last_sample_at = Time.now

        while @running
          sleep 1
          record_metrics(launcher.stats) if should_sample?
        end
      end

      def should_sample?
        Time.now - @last_sample_at > sampling_interval
      end

      def stop
        @running = false
      end

      def log(message)
        launcher.log_writer.log(message)
      end

      def record_metrics(stats)
        log("NewRelic Sampler collecting metrics with Agent #{::NewRelic::Agent.agent.inspect}")

        @last_sample_at = Time.now
        metrics = Hash.new { |h, k| h[k] = 0 }

        if stats[:worker_status] # Cluster mode
          metrics[:workers_count] = stats[:workers]
          stats[:worker_status].each do |worker|
            worker[:last_status].each { |key, value| metrics[key] += value if METRICS.include?(key) }
          end
        else # Single mode
          metrics[:workers_count] = 1
          stats.each { |key, value| metrics[key] += value if METRICS.include?(key) }
        end

        metrics.each do |key, value|
          log("Record metric: Custom/Puma/#{key}=#{value}")
          ::NewRelic::Agent.record_metric("Custom/Puma/#{key}", value)
        end
      end
    end
  end
end
