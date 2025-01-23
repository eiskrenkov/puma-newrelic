require "yaml"
require "faraday"

module Puma
  module NewRelic
    class Sampler
      def initialize(launcher)
        @newrelic_config = YAML.load_file("config/newrelic.yml", aliases: true)[ENV["RAILS_ENV"]] || {}
        config = @newrelic_config['puma'] || {}
        @launcher = launcher
        @sample_rate = config.fetch("sample_rate", 23)
        @keys = config.fetch("keys", %i[backlog running pool_capacity max_threads requests_count]).map(&:to_sym)
        @last_sample_at = Time.now
        @conn = Faraday.new(url: "https://metric-api.eu.newrelic.com/metric/v1") do |faraday|
          faraday.headers["Content-Type"] = "application/json"
          faraday.headers["Api-Key"] = @newrelic_config["license_key"]
          faraday.adapter Faraday.default_adapter
        end
      end

      def collect
        return unless agent_enabled?

        @running = true
        while @running
          sleep 1

          if should_sample?
            @last_sample_at = Time.now
            record_metrics(@launcher.stats)
          end
        end
      end

      def agent_enabled?
        @newrelic_config["agent_enabled"]
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

        payload = [
          {
            common: {
              timestamp: Time.now.to_i,
              "interval.ms": @sample_rate * 1000,
              attributes: {
                "app.name": @newrelic_config["app_name"]
              }
            },
            metrics: []
          }
        ]
        metrics.each do |key, value|
          payload[0]["metrics"] << {
            name: "Custom/Puma/#{key}",
            type: "count",
            value: value
          }
        end

        response = @conn.post do |req|
          req.body = payload.to_json
        end

        if response.status != 202
          @launcher.log_writer.write("Failed to send metrics to New Relic: #{response.status} - #{response.body}")
        end

        # metrics.each do |key, value|
        #   ::NewRelic::Agent.logger.info("Recorded metric: Custom/Puma/#{key}=#{value}")
        #   ::NewRelic::Agent.record_metric("Custom/Puma/#{key}", value)
        # end
      end
    end
  end
end
