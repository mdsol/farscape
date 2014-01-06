require 'farscape/helpers'
require 'farscape/agent/http_client'
require 'farscape/agent/request'

module Farscape
  ##
  # Agent used to make requests that wraps and delegates to configured clients specific to particular schemes.
  class Agent
    include Helpers
    
    ##
    # Invokes a request using a client configured for the resource URL scheme. Accepts a hash of request options,
    # a Farscape::Agent::Request object, or yields a block or a combination thereof. The yielded request overrides
    # values set directly as arguments.
    # 
    # @example
    #   agent = Farscape::Agent.new
    #
    #   # The following are equivalent
    #   options = {
    #     url: 'http://example.org',
    #     method: 'POST',
    #     params: {page: 1, per_page: 2},
    #     headers: {'Content-Type' => 'application/json'},
    #     body: {name: "Ka D'Argo"},
    #     connection: double('faraday_connection'),
    #     connection_options: {some: 'options'},
    #     env_options: {add_to: 'rack_env'}
    #   }
    #   result = agent.invoke(options)
    #
    #   request = Faraday::Agent::Request.new(options)
    #   result = agent.invoke(request)
    #
    #   result = agent.invoke do |request|
    #     request.url 'http://example.org'
    #     request.method = 'POST',
    #     request.params = { page: 1, per_page: 2 },
    #     request.headers = { 'Content-Type' => 'application/json' },
    #     request.body = { name: "Ka D'Argo" },
    #     request.connection = double( 'faraday_connection' ),
    #     request.connection_options = { some: 'options' },
    #     request.env_options = { add_to: 'rack_env' }
    #   end
    #
    # @param [Hash, Farscape::Agent::Request] request The request object.
    # 
    # @return [Farscape::Agent::Result] The encapsulated result.
    def invoke(request = nil)
      request = build_request(request)
      yield request if block_given?
      client = retrieve_client(request)
      client.invoke(request)
    end

    private
    def build_request(request)
      Request.build_or_return(request)
    end
    
    def retrieve_client(request)
      config.clients[request.scheme].tap do |client|
        raise UnregisteredClientError, "No client registered for scheme: '#{request.scheme}'." unless client
      end
    end
    
    class UnregisteredClientError < StandardError; end
  end
end
