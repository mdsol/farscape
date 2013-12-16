require 'spec_helper'
require 'farscape/agent/request'

module Farscape
  class Agent
    describe Request do
      let(:options) do
        {
          url: 'http://example.org',
          method: 'POST',
          params: {page: 1, per_page: 2},
          headers: {'Content-Type' => 'application/json'},
          body: {name: "Ka D'Argo"},
          connection: double('faraday_connection'),
          connection_options: { some: 'options' },
          env_options: {add_to: 'rack_env'}
        }
      end
      let(:hash) { options }
      let(:subject) { Request.new(options) }
      
      describe '#lock!' do
        it 'freezes the request' do
          subject.lock!
          expect { subject.method = 'anything' }.to raise_error(Farscape::Agent::RequestLockedError)
        end
        
        it 'returns the locked request' do
          locked_request = subject.lock!
          locked_request.object_id.should == subject.object_id
        end
      end
      
      describe '#locked?' do
        it 'returns false when the request is not locked' do
          subject.locked?.should be_false
        end

        it 'returns true when the request is locked' do
          subject.lock!
          subject.locked?.should be_true
        end
      end
      
      describe '#scheme' do
        context 'with a blank url' do
          it 'returns nil' do
            options.delete(:url)
            subject.scheme.should be_nil
          end
        end
        
        context 'with a scheme-less url' do
          it 'returns nil' do
            subject.url = 'example.org'
            subject.scheme.should be_nil
          end
        end
        
        context 'with a full url' do
          it 'returns the url scheme as a symbol' do
            subject.scheme.should == :http
          end
        end    
      end
      
      describe '#url' do
        it 'returns the url specified in the options' do
          subject.url.should == 'http://example.org'
        end
        
        it 'updates url and resets the scheme' do
          subject.url = 'https://example.org'
          subject.scheme.should == :https
        end
      end
      
      describe '#to_env' do
        let(:connection) { Faraday::Connection.new }
        
        it 'returns an environment hash when valid' do
          env = {
            add_to: 'rack_env',
            body: {name: "Ka D'Argo"},
            method: 'post',
            parallel_manager: nil,
            request: {some: 'options'},
            request_headers: {'Content-Type' => 'application/json'},
            ssl: {},
            url: 'http://example.org?page=1&per_page=2'
          }
          request_env = subject.to_env(connection)
          
          env.all? { |k, v| request_env[k].to_s == v.to_s }.should be_true
        end
        
        it 'raises an error without a URL' do
          options.delete(:url)
          expect { subject.to_env(connection) }.to raise_error(MalformedRequestError)
        end
        
        it 'raises an error without an absolute URL' do
          options[:url] = 'example.org'
          expect { subject.to_env(connection) }.to raise_error(MalformedRequestError)
        end

        it 'raises an error without a method' do
          options.delete(:url)
          expect { subject.to_env(connection) }.to raise_error(MalformedRequestError)
        end

        it 'raises an error for non-hash params' do
          options[:params] = double('invalid_params')
          expect { subject.to_env(connection) }.to raise_error(MalformedRequestError)
        end

        it 'raises an error for non-hash headers' do
          options[:headers] = double('invalid_headers')
          expect { subject.to_env(connection) }.to raise_error(MalformedRequestError)
        end
        
        it 'raises an error if the connection does not implement a #build_request method' do
          connection = double('connection')
          expect { subject.to_env(connection) }.to raise_error(ArgumentError)
        end
      end
  
      describe '#to_hash' do
        it 'returns the request values as a hash' do
          subject.to_hash.should == hash
        end
      end
    end
  end
end
