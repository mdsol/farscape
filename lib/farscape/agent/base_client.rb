require 'faraday'
require 'farscape/helpers'
require 'farscape/agent/request'

module Farscape
  class Agent
    class BaseClient
      extend ::Farscape::Helpers
      
      def self.client_factory
        config.client_factory
      end
      private_class_method :client_factory
      
      def self.schemes(*schemes)
        schemes.map(&:to_sym).each { |scheme| client_factory.register(scheme, self) }
      end
      private_class_method :schemes

      ##
      # The Faraday connection instance.
      attr_reader :connection

      ##
      # @param [Hash] options Optional Faraday configuration.
      def initialize(options = {})
        @connection = Faraday.new(options) do |faraday|
          faraday.adapter default_adapter
          yield faraday if block_given?
        end
      end

      ##
      # Transmits the request.
      #
      # @param [Hash, Farscape::Agent::Request] request The request to invoke.
      def invoke(request = nil)
        request = build_request(request)
        yield request if block_given?
        request.lock!
        transmit(request)
      end

      private
      def build_request(request)
        Request.build_or_return(request)
      end

      def default_adapter
        :net_http
      end

      def transmit(request)
        request_connection = request.connection || connection
        request_env = request.to_env(request_connection)
        request_env = serialize_body(request_env)
        
        request_connection.app.call(request_env)
      end
      
      def serialize_body(env)
        env.tap do |e|
          e[:body] = e[:body].to_json if e[:body] # TODO add serialization for Content-type
        end
      end
    end
  end
end
