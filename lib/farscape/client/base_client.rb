module Farscape
  class Agent
    # Client independent of protocol, only used for HTTP for now
    class BaseClient

      def interface_methods
        {
          safe: [],
          unsafe: [],
          idempotent: []
        }
      end

      def safe_method?(meth)
        interface_methods[:safe].include?(meth)
      end

      def unsafe_method?(meth)
        interface_methods[:unsafe].include?(meth)
      end

      def idempotent_method?(meth)
        interface_methods[:idempotent].include?(meth)
      end
    end
  end
end
