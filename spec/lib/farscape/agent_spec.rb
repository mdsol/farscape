require 'spec_helper'
require 'farscape/agent'

module Farscape
  describe Agent do 
    let(:agent) { Agent.new }
    let(:http_client) { double('http_client') }
    let(:config) { Farscape::Configuration.config }
    let(:options) { { url: 'http://example.org' } }
    let(:request) { Agent::Request.new(options) }
     
    describe '#invoke' do
      context 'with valid arguments' do
        context 'with known scheme' do
          before do
            config.stub(:clients).and_return({ http: http_client })
          end
          
          it 'delegates the request to the underlying scheme client' do
            http_client.should_receive(:invoke).with(request)
            agent.invoke(request)
          end
          
          it 'builds a request from the options delegates the request to the underlying scheme client' do
            agent.invoke(options) do |request|
              http_client.should_receive(:invoke).with(request)
            end
          end

          it 'yields a request and delegates the request to the underlying scheme client' do
            agent.invoke do |request|
              request.url = 'http://example.org'
              http_client.should_receive(:invoke).with(request)
            end
          end
        end
        
        context 'without known scheme' do
          it 'raises an error for a non-existent scheme' do
            expect { agent.invoke(url: 'bogus_scheme://example.org') }.to raise_error(Agent::UnregisteredClientError)
          end
  
          it 'raises an error for a relative URL' do
            expect { agent.invoke(url: 'example.org') }.to raise_error(Agent::UnregisteredClientError)
          end
  
          it 'raises an error for a nil argument without a block to set a valid url' do
            expect { agent.invoke(url: 'example.org') }.to raise_error(Agent::UnregisteredClientError)
          end
        end
      end
      
      context 'without valid arguments' do
        it 'raises an error' do
          expect { subject.invoke(double('invalid_argument')) }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
