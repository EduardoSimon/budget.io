ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Includes helper method for creating instances: #https://github.com/thoughtbot/factory_bot/wiki/Integration%3A-minitest-rails
  include FactoryBot::Syntax::Methods
end
