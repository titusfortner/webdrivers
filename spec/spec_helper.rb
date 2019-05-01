# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'rspec'
require 'webdrivers'

RSpec.configure do |config|
  config.filter_run_including focus: true unless ENV['CI']
  config.run_all_when_everything_filtered = true
end
