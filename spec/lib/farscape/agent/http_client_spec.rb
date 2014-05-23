require 'spec_helper'
require 'farscape/agent/http_client'

module Farscape
  class Agent
    describe HTTPClient do
      
      describe '#invoke' do
        let(:subject) { HTTPClient.new }
        let(:options) do
          {
            url: 'http://example.org',
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
            stub_request(:post, 'http://example.org/?page=1&per_page=2').
              with(:body => {'name' => "Ka D'Argo"}.to_json,
              :headers => {'Accept' => '*/*', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby'}).
              to_return(:status => 200, :body => '', :headers => {})
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
                builder.url         = options[:url]
                builder.method      = options[:method]
                builder.params      = options[:params]
                builder.headers     = options[:headers]
                builder.body        = options[:body]
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
