require 'spec_helper'
require 'farscape/agent'

module Farscape
  describe Agent do 
    let(:agent) { Agent.new }
    let(:http_client) { double('http_client') }
    let(:tcp_client) { double('tcp_client')}
    let(:config) { Farscape::Configuration.config }
    let(:options) { { url: @url } }
    let(:request) { Agent::Request.new(options) }
     
    describe '#invoke' do
      context 'with valid arguments' do
        it 'defaults to using an HTTP client if no clients are configured' do
          @url = 'http://example.org'
          config.client_factory.stub(:build).with(:http).and_return(http_client)
          http_client.should_receive(:invoke).with(request)
          agent.invoke(request)
        end
        
        shared_examples_for 'a request with a known scheme' do
          before do
            config.stub(:clients).and_return({http: http_client, tcp: tcp_client})
          end
          
          it 'delegates the request to the underlying scheme client' do
            client.should_receive(:invoke).with(request)
            agent.invoke(request)
          end
          
          it 'builds a request from the options delegates the request to the underlying scheme client' do
            agent.invoke(options) do |request|
              client.should_receive(:invoke).with(request)
            end
          end

          it 'yields a request and delegates the request to the underlying scheme client' do
            agent.invoke do |request|
              request.url = @url
              client.should_receive(:invoke).with(request)
            end
          end
        end
        
        context 'with http scheme' do
          let(:client) { http_client }
          
          before do
            @url = 'http://example.org'
          end

          it_behaves_like 'a request with a known scheme'
        end

        context 'with tcp scheme' do
          let(:client) { tcp_client }

          before do
            @url = 'tcp://1.2.3.4:5678'
          end

          it_behaves_like 'a request with a known scheme'
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
