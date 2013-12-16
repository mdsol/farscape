require 'spec_helper'
require 'farscape/agent/base_client'

module Farscape
  class Agent
    describe BaseClient do
      describe '.new' do
        it 'yields a Faraday connection to configure' do
          BaseClient.new do |builder|
            builder.should be_instance_of(Faraday::Connection)
          end
        end
      end

      describe '#connection' do
        it 'returns Faraday connection configured for the agent' do
          conn = nil
          agent = BaseClient.new { |connection| conn = connection }

          agent.connection.should == conn
        end
      end
    end
  end
end
