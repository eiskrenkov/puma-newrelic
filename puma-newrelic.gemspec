# frozen_string_literal: true

require_relative "lib/puma/new_relic/version"

Gem::Specification.new do |spec|
  spec.name = "puma-newrelic"
  spec.version = Puma::NewRelic::VERSION
  spec.authors = ["Benoist Claassen"]
  spec.email = ["benoist.claassen@gmail.com"]

  spec.summary = "New Relic Puma Stats sampler"
  spec.description = "Samples the puma stats and creates a custom metric for NewRelic"
  spec.homepage = "https://github.com/codeur/puma-newrelic"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage

  spec.files         = Dir["{lib}/**/*.{rb}", "Rakefile", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "puma", "~> 6.0"
  spec.add_dependency "newrelic_rpm", "~> 9.0"
end
