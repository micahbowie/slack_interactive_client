require "bundler/setup"
require "byebug"
require 'rails'

require "slack_interactive_client"

ENV['RAILS_ENV'] ||= 'test'

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end