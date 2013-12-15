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
      let(:request) { Request.new(options) }
      
      describe '#lock!' do
        it 'freezes the request' do
          request.lock!
          expect { request.method = 'anything' }.to raise_error(Farscape::Agent::ReferenceLockedError)
        end
        
        it 'returns the locked request' do
          locked_request = request.lock!
          locked_request.object_id.should == request.object_id
        end
      end
      
      describe '#locked?' do
        it 'returns false when the request is not locked' do
          request.locked?.should be_false
        end

        it 'returns true when the request is locked' do
          request.lock!
          request.locked?.should be_true
        end
      end
      
      describe '#scheme' do
        context 'with a blank url' do
          it 'returns nil' do
            options.delete(:url)
            request.scheme.should be_nil
          end
        end
        
        context 'with a scheme-less url' do
          it 'returns nil' do
            request.url = 'example.org'
            request.scheme.should be_nil
          end
        end
        
        context 'with a full url' do
          it 'returns the url scheme as a symbol' do
            request.scheme.should == :http
          end
        end    
      end
      
      describe '#url' do
        it 'returns the url specified in the options' do
          request.url.should == 'http://example.org'
        end
        
        it 'updates url and resets the scheme' do
          request.url = 'https://example.org'
          request.scheme.should == :https
        end
      end
  
      describe '#to_hash' do
        it 'returns the request values as a hash' do
          request.to_hash.should == hash
        end
      end
    end
  end
end
