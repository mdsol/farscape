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
    end
  end
end
