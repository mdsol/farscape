require 'faraday'
require 'farscape/client/base_client'
require 'farscape/plugins'

module Farscape
  class Agent
    class HTTPClient < BaseClient

      # The Faraday connection instance.
      attr_reader :connection

      def initialize
        @connection = Faraday.new do |builder|
          Farscape.middleware_stack.each do |middleware|
            if middleware.key?(:config)
              config = middleware[:config]
              if config.is_a?(Array)
                builder.use(middleware[:class], *config)
              else
                builder.use(middleware[:class], config)
              end
            else
              builder.use(middleware[:class])
            end
          end
          builder.request :url_encoded
          builder.adapter faraday_adapter
        end
      end

      # Override this in a subclass to create clients with custom Faraday adapters
      def faraday_adapter
        Faraday.default_adapter
      end

      ##
      # Makes a Faraday request given the specified options
      #
      # @options [Hash] The hash of Faraday options passed to the request, including url, method,
      #  params, body, and headers.
      # @return [Faraday::Response] The response object resulting from the Faraday call
      def invoke(options = {})
        defaults = { url:     '',
                     method:  'get',
                     params:  {},
                     body:    '',
                     headers: {}
                    }
        options = defaults.merge(options)

        connection.send(options[:method].to_s.downcase) do |req|
          req.url options[:url]
          req.body = options[:body]
          options[:params].each { |k,v| req.params[k] = v }
          options[:headers].each { |k,v| req.headers[k] = v }
        end
      end
    end
  end
end
