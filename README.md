# Puma::NewRelic

This is a Puma plugin for NewRelic custom metrics.
It will sample the Puma stats and create a custom metric for NewRelic.
You can view the information in the NewRelic insights or in NewRelic One.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'puma-newrelic'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install puma-newrelic

## Usage

- Install the gem
- Add `plugin :new_relic` to your puma.rb
- Create a dashboard on the NewRelic insights or NewRelic One

NQRL example:

```SQL
SELECT rate(average(newrelic.timeslice.value), 1 minute)
FROM Metric
WHERE appName ='My App Name'
WITH METRIC_FORMAT 'Custom/Puma/pool_capacity'
TIMESERIES FACET `host` LIMIT 10 SINCE 1800 seconds ago
```

## Extra config in newrelic.yml

```yaml
common: &default_settings
  puma:
    sample_interval: 15
    keys:
      - backlog
      - running
      - pool_capacity
      - max_threads
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
