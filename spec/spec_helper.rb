# frozen_string_literal: true
require 'factory_girl_rails'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.color = true
  config.order = :random
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?

  Kernel.srand config.seed
end
