require "bundler/setup"
require "smart_id"

RSpec.configure do |config|
  # Set SMART ID demo parameters
  config.before(:each) do 
    SmartId.configure do |config|
      config.relying_party_uuid = "00000000-0000-0000-0000-000000000000"
      config.relying_party_name = "DEMO"
      config.default_certificate_level = "QUALIFIED"
      config.environment = "demo"
    end
  end
  
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
