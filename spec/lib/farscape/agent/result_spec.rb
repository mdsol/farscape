require 'spec_helper'
require 'farscape/agent/result'

module Farscape
  class Agent
    describe Result do
      let(:headers) { {'Content-Type' => 'application/hal+json'} }
      let(:request) { double('request') }
      let(:response) do 
        double('response').tap do |r|
          r.stub(:status).and_return(200)
          r.stub(:headers).and_return(headers)
          r.stub(:body).and_return(@body)
        end
      end
      let(:result) { Result.new(request, response) }

      describe '#body' do
        it 'returns the body in the response' do
          @body = double('body')
          result.body.should == @body
        end
      end
      
      describe '#headers' do
        it 'returns the headers in the response' do
          result.headers.should == headers
        end
      end

      describe '#request' do
        it 'returns the request object' do
          result.request.should == request
        end
      end
      
      describe '#response' do
        it 'returns the response object' do
          result.response.should == response
        end
      end
      
      describe '#status' do
        it 'returns the response status code' do
          result.status.should == 200
        end
      end
    end
  end
end
