require 'spec_helper'
require 'farscape/configuration/base'

module Farscape
  module Configuration
    describe Base do
      let(:client_factory) { double('client_factory') }
      let(:subject) { Base.new(client_factory) }
      
      describe '#client' do
        it 'passes arguments to the client factory' do
          client = double('https_client')
          options = double('options')
          client_factory.should_receive(:build).with(:http, options).and_return(client)

          subject.client(:http, options)
        end
        
        it 'passes a block to the client factory' do
          factory_builder = double('factory_builder')
          client_factory.stub(:build).with(:http, anything).and_yield(factory_builder)
          
          subject.client(:http) do |builder|
            builder.should == factory_builder
          end
        end
      end
      
      describe '#clients' do
        it 'memoizes' do
          clients = subject.clients
          subject.clients.object_id.should == clients.object_id
        end
        
        it 'returns an empty hash if no clients have been configured' do
          subject.clients.should be_empty
        end
        
        it 'returns a hash of configured clients' do
          client = double('https_client')
          client_factory.stub(:build).with(anything, anything).and_return(client)
          subject.client(:http, 'https')
          
          subject.clients.should == { http: client, https: client }
        end
      end
      
      describe '#client_factory' do
        it 'returns the client factory passed to the constructor' do
          subject.client_factory.should == client_factory
        end
      end
      
      describe '#defaults' do
        it 'yields a Faraday::Connection instance' do
          subject.defaults do |builder|
            builder.should be_instance_of(Faraday::Connection)
          end
        end
        
        it 'passes options to the constructed connection' do
          options = double('options')
          connection = mock('connection').tap { |c| c.stub(:builder) }

          Faraday::Connection.should_receive(:new).with(options).and_return(connection)
          subject.defaults(options)
        end
      end
    end
  end
end
