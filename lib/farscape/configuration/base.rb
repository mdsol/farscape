require 'faraday'

module Farscape
  module Configuration
    # Manages the configuration of Farscape.
    class Base
      attr_reader :client_factory
      
      def initialize(client_factory)
        @client_factory = client_factory
      end
      
      def client(*args, &block)
        schemes, options = args.partition { |arg| arg.is_a?(Symbol) || arg.is_a?(String) }
        options = options.first
        options.merge!({ builder: @default_builder.dup }) if options && @default_builder

        schemes.map(&:to_sym).each { |scheme| clients[scheme] = client_factory.build(scheme, options || {}, &block) }
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
