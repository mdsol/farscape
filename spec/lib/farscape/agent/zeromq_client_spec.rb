require 'spec_helper'
require 'farscape/agent/zeromq_client'

module Farscape
  class Agent
    describe ZeromqClient do
      # Note: This class is copied from faraday-zeromq, but not used completely at this point as we are not trying
      # to test the faraday adapter. However, in the future, this may be useful for more detailed testing.
      class FakeSocket
        attr_reader :sent

        def initialize(responses)
          @sent = []
          @responses = responses.empty? ? [YAML.dump([200, {}]), 'ok'] : responses
        end

        def send_string(str, flags = 0)
          @sent << [str, flags]
        end

        def recv_string(s)
          s.replace @responses.shift
        end

        def connect(*); end # Do nothing
      end
      
      def build_socket(meta = nil, body = nil)
        FakeSocket.new(meta ? [YAML.dump(meta), body] : [])
      end

      let(:config) { Farscape::Configuration.config }

      after do
        Farscape.send(:reset_config)
      end

      it 'self registers itself in the client factory' do
        client_factory = config.client_factory
        client_factory.registered_classes[:tcp].should == ZeromqClient
      end

      describe '#invoke' do
        let(:subject) { ZeromqClient.new }
        let(:options) do
          {
            url: 'tcp://127.0.0.1:1',
            method: 'POST',
            params: {page: 1, per_page: 2},
            headers: {'Content-Type' => 'application/json'},
            body: {name: "Ka D'Argo"},
            connection_options: {some: 'options'},
            env_options: {add_to: 'rack_env'}
          }
        end

        it 'raises an error for an invalid argument' do
          expect { subject.invoke(double('invalid_argument')) }.to raise_error(ArgumentError)
        end

        context 'with valid arguments' do
          before do
            context = double('context')
            context.stub(:socket).with(anything).and_return(build_socket)
            ZMQ::Context.stub(:new).and_return(context)
          end

          context 'with a hash containing request parameters' do
            it 'transmits a request' do
              subject.invoke(options).should be_instance_of(Result)
            end
          end

          context 'with a request object argument' do
            it 'transmits a request' do
              request = Request.new(options)
              subject.invoke(request).should be_instance_of(Result)
            end
          end

          context 'with a block' do
            it 'transmits a request' do
              response = subject.invoke do |builder|
                builder.url = options[:url]
                builder.method = options[:method]
                builder.params = options[:params]
                builder.headers = options[:headers]
                builder.body = options[:body]
                builder.env_options = options[:env_options]
                builder.connection_options = options[:connection_options]
              end

              response.should be_instance_of(Result)
            end
          end
        end
      end
    end
  end
end
