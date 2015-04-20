require 'spec_helper'

describe Farscape::Agent::HTTPClient do

  describe 'initializer' do
    it 'uses redirect middlware' do
      agent = double('an agent')
      allow(agent).to receive(:middleware_stack).and_return([])
      client = Farscape::Agent::HTTPClient.new(agent)
      expect(client.connection.builder.handlers.any?{|handler| handler.name == 'FaradayMiddleware::FollowRedirects'}).to eq(true)
    end
  end

end
