require_relative "../newrelic/plugin"

Puma::Plugin.create do
  include Puma::NewRelic::Plugin
end
