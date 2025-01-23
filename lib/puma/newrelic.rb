# frozen_string_literal: true

require_relative "newrelic/version"

module Puma
  module NewRelic
    class Error < StandardError; end
    # Your code goes here...
  end
end

require_relative "plugin"
