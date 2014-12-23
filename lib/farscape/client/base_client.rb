module Farscape
  class Agent
    # Client independent of protocol, only used for HTTP for now
    class BaseClient

      def methods
        {
          safe: [],
          unsafe: [],
          idempotent: []
        }
      end

      def safe_methods
        methods[:safe]
      end

      def unsafe_methods
        methods[:unsafe]
      end

      def idempotent_methods
        methods[:idempotent]
      end
    end
  end
end
