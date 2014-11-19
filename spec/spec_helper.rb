RAILS_PORT = 1234
SPEC_DIR = File.expand_path("..", __FILE__)
lib_dir = File.expand_path("../lib", SPEC_DIR)


$LOAD_PATH.unshift(lib_dir)
$LOAD_PATH.uniq!

require 'rspec'
require 'debugger'
require 'bundler'
require 'webmock/rspec'
require 'simplecov'
require 'crichton_test_service'

SimpleCov.start
Debugger.start
Bundler.setup

require 'farscape'
CrichtonTestService.initialize_rails!

Dir["#{SPEC_DIR}/support/*.rb"].each { |f| require f }

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random' unless ENV['RANDOMIZE'] == 'false'

  config.include Support::Helpers
  config.include Support::DiceBagHelpers

  config.before(:suite) do
    old_handler = trap(:INT) {
      Process.kill(:INT, @rails_pid) if @rails_pid
      old_handler.call if old_handler.respond_to?(:call)
    }
    WebMock.disable!
    @rails_pid = CrichtonTestService.spawn_rails_process!(RAILS_PORT)
  end

  config.after(:suite) do
    Process.kill(:INT, @rails_pid) if @rails_pid
  end
end
