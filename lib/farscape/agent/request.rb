require 'addressable/uri'

module Farscape
  class Agent
    ##
    # Data object that manages request related options.
    class Request
      # @private
      ATTRIBUTES = %w(url method params body headers connection connection_options env_options).map(&:to_sym)
      
      ATTRIBUTES.each do |attribute|
        define_method(attribute) { @attributes[attribute] }
        define_method("#{attribute}=") do |value| 
          check_locked proc { @attributes[attribute] = value }
        end
      end

      def initialize(options = {})
        @attributes = {}
        ATTRIBUTES.each { |attribute| @attributes[attribute] = options[attribute] }
      end
      
      def lock!
        @attributes.freeze
        self
      end
      
      def locked?
        @attributes.frozen?
      end
      
      def scheme
        @scheme ||= if uri = Addressable::URI.parse(url)
          uri.scheme.downcase.to_sym if uri.scheme
        end 
      end
      
      def to_env(connection)
        unless connection.respond_to?(:build_request)
          raise ArgumentError, "connection object must implement #build_request method."
        end
        validate_attributes!

        build_env(connection)
      end
      
      def to_hash
        ATTRIBUTES.each_with_object({}) { |attribute, h| h[attribute] = send(attribute) }
      end

      def url=(value)
        check_locked proc { @attributes[:url], @scheme = value, nil }
      end
      
      private
      def check_locked(proc)
        raise RequestLockedError, "You are attempting to modify a locked Request object #{self.inspect}." if locked?
        proc.call 
      end
      
      def build_env(connection)
        request = build_faraday_request(connection)
        request.to_env(connection).tap do |e|
          (env_options || {}).each { |k, v| e[k] = v } # Passes options into env for middleware access
        end
      end
      
      def build_faraday_request(connection)
        connection.build_request(method.downcase) do |req|
          req.url       url     if url
          req.params  = params  if params
          req.headers = headers if headers
          req.body    = body    if body
          req.options = connection_options if connection_options
        end
      end

      def validate_attributes!
        msg = ''
        msg << "Invalid URL: '#{url.inspect}'. "       unless url && Addressable::URI.parse(url).absolute?
        msg << "No method specified. "                 unless method
        msg << "Invalid params: #{params.inspect}. "   if params  && !params.is_a?(Hash)
        msg << "Invalid headers: #{headers.inspect}. " if headers && !headers.is_a?(Hash)

        raise MalformedRequestError, msg unless msg.empty?
      end
    end
    
    class MalformedRequestError < StandardError; end
    class RequestLockedError < StandardError; end
  end
end
