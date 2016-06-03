require 'simplecov'
SimpleCov.start

require 'crichton'
require 'representors'
require 'moya'

require 'webmock/rspec'


RAILS_PORT = 1234
SPEC_DIR = File.expand_path("..", __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'farscape'

Dir["#{SPEC_DIR}/support/*.rb"].each { |f| require f }


WebMock.disable_net_connect!(allow_localhost: true)

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

  config.before(:suite) do
    old_handler = trap(:INT) {
      Process.kill(:INT, $moya_rails_pid) if $moya_rails_pid
      old_handler.call if old_handler.respond_to?(:call)
    }
    $moya_rails_pid = Moya.spawn_rails_process!(RAILS_PORT)
  end

  config.after(:suite) do
    Process.kill(:INT, $moya_rails_pid)
  end
end
