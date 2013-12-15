require 'faraday'

module Farscape
  module Configuration
    # Manages the configuration of Farscape.
    class Base
      attr_reader :client_factory
      
      def initialize(client_factory)
        @client_factory = client_factory
      end
      
      def client(*schemes, &block)
        options = schemes.pop unless schemes.last.is_a?(Symbol)
        
        schemes.map(&:to_sym).each do |scheme|
          options.merge!({ builder: @default_builder.dup }) if options && @default_builder
          clients[scheme] = client_factory.build(scheme, options || {}, &block)
        end 
      end
      
      def clients
        @clients ||= {}
      end

      def defaults(options = {}, &block)
        default_connection = Faraday::Connection.new(options, &block)
        @default_builder = default_connection.builder
      end
    end
  end
end
