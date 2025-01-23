require_relative "sampler"
require "puma/plugin"

module Puma
  module NewRelic
    class Plugin < Puma::Plugin
      def start(launcher)
        sampler = Puma::NewRelic::Sampler.new(launcher)
        launcher.events.register(:state) do |state|
          if %i[halt restart stop].include?(state)
            sampler.stop
          end
        end

        in_background do
          sampler.start
        end
      end
    end

    Puma::Plugins.register "newrelic", Plugin
  end
end
