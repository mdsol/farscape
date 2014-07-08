module Farscape
  class AvailableMiddleware
    class << self

      def inherited(base)
        @middlewares ||= []
        @middlewares << base
      end

      def all
        @middlewares || []
      end

      def clear_middlewares
        @middlewares = []
      end
    end

  end
end
