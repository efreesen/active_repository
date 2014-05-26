if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
end

require 'rspec'
require 'rspec/autorun'

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end
