require 'faraday'
require 'farscape/client/base_client'
require 'farscape/plugins'
require 'farscape/errors'

module Farscape
  class Agent
    class HTTPClient < BaseClient

      # The Faraday connection instance.
      attr_reader :connection

      def initialize
        @connection = Faraday.new do |builder|
          builder.request :url_encoded
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
        defaults = { method:  'get'}
        options = defaults.merge(options)

        connection.send(options[:method].to_s.downcase) do |req|
          req.url options[:url]
          req.body = options[:body] if options.has_key?(:body)
          options[:params].each { |k,v| req.params[k] = v } if options.has_key?(:params)
          options[:headers].each { |k,v| req.headers[k] = v } if options.has_key?(:headers)
        end
      end

      def interface_methods
        {
          idempotent: ['PUT', 'DELETE'],
          unsafe: ['POST', 'PATCH'], # http://tools.ietf.org/html/rfc5789
          safe: ['GET', 'HEAD', 'OPTIONS', 'TRACE', 'CONNECT']
        }
      end

      def dispatch_error(response)
        errors = Farscape::Exceptions
        http_code = {
          400 => errors::BadRequest,
          401 => errors::Unauthorized,
          403 => errors::Forbidden,
          404 => errors::NotFound,
          405 => errors::MethodNotAllowed,
          406 => errors::NotAcceptable,
          407 => errors::ProxyAuthenticationRequired,
          408 => errors::RequestTimeout,
          409 => errors::Conflict,
          410 => errors::Gone,
          411 => errors::LengthRequired,
          412 => errors::PreconditionFailed,
          413 => errors::RequestEntityTooLarge,
          414 => errors::RequestUriTooLong,
          415 => errors::UnsupportedMediaType,
          416 => errors::RequestedRangeNotSatisfiable,
          417 => errors::ExpectationFailed,
          418 => errors::ImaTeapot,
          422 => errors::UnprocessableEntity,
          500 => errors::InternalServerError,
          501 => errors::NotImplemented,
          502 => errors::BadGateway,
          503 => errors::ServiceUnavailable,
          504 => errors::GatewayTimeout,
          505 => errors::ProtocolVersionNotSupported,
        }
        http_code[response.status] || errors::ProtocolException unless response.success?
      end

    end
  end
end
