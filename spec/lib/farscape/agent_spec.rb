require 'spec_helper'
require 'farscape/agent'

module Farscape
  describe Agent do
    let(:agent) { Agent.new }
    let(:http_client) { double('http_client') }
    let(:config) { Farscape::Configuration.config }
    let(:options) { { url: @url, method: :get } }
    let(:request) { Agent::Request.new(options) }

    describe '#invoke' do
      context 'with valid arguments' do
        context 'with http scheme' do

          before do
            @url = 'http://example.org'
          end

          it 'delegates the request to the underlying scheme client' do
            allow_any_instance_of(Agent::HTTPClient).to receive(:invoke).with(request).and_return("")
            agent.invoke(request)
          end

        end

        context 'without known scheme' do
          it 'raises an error for a non-existent scheme' do
            request = Agent::Request.new(url: 'bogus_scheme://example.org')
            expect { agent.invoke(request) }.to raise_error(Agent::UnregisteredClientError)
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
