require_relative "spec_helper"

Sepass::Container.start :persistence

Dir[SPEC_ROOT.join("support/db/*.rb").to_s].each(&method(:require))
Dir[SPEC_ROOT.join("shared/db/*.rb").to_s].each(&method(:require))

require "database_cleaner"
DatabaseCleaner[:sequel, connection: Test::DatabaseHelpers.db].strategy = :truncation

RSpec.configure do |config|
  config.include Test::DatabaseHelpers

  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  config.around :each do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
