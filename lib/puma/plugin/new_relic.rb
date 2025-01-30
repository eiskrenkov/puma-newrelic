require "puma"
require 'puma/new_relic/sampler'

Puma::Plugin.create do
  def start(launcher)
    sampler = Puma::NewRelic::Sampler.new(launcher)
    return unless sampler.enabled?

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
