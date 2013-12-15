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
      
      def to_hash
        ATTRIBUTES.each_with_object({}) { |attribute, h| h[attribute] = send(attribute) }
      end

      def url=(value)
        check_locked proc { @attributes[:url], @scheme = value, nil }
      end
      
      private
      def check_locked(proc)
        raise ReferenceLockedError, "You are attempting to modify a locked Reference #{self.inspect}." if locked?
        proc.call 
      end
    end
    
    class ReferenceLockedError < StandardError; end
  end
end
