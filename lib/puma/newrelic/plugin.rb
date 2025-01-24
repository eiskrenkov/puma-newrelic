require_relative "sampler"

module Puma
  module NewRelic
    module Plugin
      def start(launcher)
        sampler = Puma::NewRelic::Sampler.new(launcher)

        launcher.events.register(:state) do |state|
          if %i[halt restart stop].include?(state)
            sampler.stop
          end
        end

        in_background do
          sampler.collect
        end
      end
    end
  end
end
