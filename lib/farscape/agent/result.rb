module Farscape
  class Agent
    class Result < Struct.new(:request, :response)
      extend Forwardable
      
      def_delegators :response, :status, :headers, :body

    end
  end
end
