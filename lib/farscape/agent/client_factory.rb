module Farscape
  class Agent
    class ClientFactory
      def self.build(scheme, options = {}, &block)
        unless klass = registered_classes[scheme.to_sym]
          msg = "No client class is registered for the scheme '#{scheme}'. " <<
            "Clients are registered for '#{registered_classes.keys.join(',')}' schemes."
          raise UnregisteredClientError, msg
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
