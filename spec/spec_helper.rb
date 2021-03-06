$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'api_dot_ai'

project_root = File.dirname(File.absolute_path(__FILE__))
support_path = "#{project_root}/support/**/*.rb"
Dir.glob(support_path) { |f| require_relative f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
