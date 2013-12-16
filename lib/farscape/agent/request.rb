require 'addressable/uri'

module Farscape
  class Agent
    ##
    # Data object that manages request related options.
    class Request
      # @private
      ATTRIBUTES = %w(url method params body headers connection connection_options env_options).map(&:to_sym)
      
      attr_accessor *ATTRIBUTES

      def initialize(options = {})
        ATTRIBUTES.each { |attribute| instance_variable_set("@#{attribute}", options[attribute]) }
      end
      
      def lock!
        self.freeze
        self
      end
      
      def locked?
        self.frozen?
      end
      
      def scheme
        @scheme ||= if uri = Addressable::URI.parse(url)
          uri.scheme.downcase.to_sym if uri.scheme
        end 
      end
      
      def to_env(connection)
        request = build_faraday_request(connection)
        request.to_env(connection).tap do |e|
          (env_options || {}).each { |k, v| e[k] = v } # Passes options into env for middleware access
        end
      end
      
      def to_hash
        ATTRIBUTES.each_with_object({}) { |attribute, h| h[attribute] = send(attribute) }
      end

      def url=(value)
        @url, @scheme = value, nil
      end
      
      private
      def build_faraday_request(connection)
        validate_attributes!

        connection.build_request(method.downcase) do |req|
          req.url url if url
          req.params = params if params
          req.headers = headers if headers
          req.body = body if body
          req.options = connection_options if connection_options
        end
      end

      def validate_attributes!
        msg = ''
        msg << "Invalid URL: '#{url.inspect}'. " unless url && Addressable::URI.parse(url).absolute?
        msg << "No method specified. " unless method
        msg << "Invalid params: #{params.inspect}. " if params && !params.is_a?(Hash)
        msg << "Invalid headers: #{headers.inspect}. " if headers && !headers.is_a?(Hash)

        raise MalformedRequestError, msg unless msg.empty?
      end
    end
    
    class MalformedRequestError < StandardError; end
  end
end
