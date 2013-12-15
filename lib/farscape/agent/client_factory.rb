module Farscape
  class Agent
    class ClientFactory
      def self.build(scheme, options = {}, &block)
        unless klass = registered_classes[scheme.to_sym]
          raise UnregisteredClientError, "No client class is registered for the scheme '#{scheme}'."
        end
        klass.new(options, &block)
      end
      
      def self.register(scheme, klass)
        registered_classes[scheme.to_sym] = klass
      end
      
      def self.registered_classes
        @registered_classes ||= {}
      end
    end
    
    class UnregisteredClientError < StandardError; end
  end
end
