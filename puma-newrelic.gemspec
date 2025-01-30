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

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "puma", "~> 6.0"
  spec.add_dependency "newrelic_rpm", "~> 9.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
