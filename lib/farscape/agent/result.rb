require 'representors'
module Farscape
  class Agent
    class Result < Struct.new(:request, :response)
      extend Forwardable

      def_delegators :response, :status, :headers, :body

      def deserialize
        deserializer = Crichton::Deserializer.create(response.headers['Content-Type'], response.body)
        deserializer.deserialize
      end

      unless ::ENV['VERBOSE_INSPECT']
        ##
        # Returns a <code>String</code> representation of the result.
        #
        # @return [String] The result, as a <code>String</code>.
        def inspect
          sprintf("#<%s:%#0x METHOD:%s URL:%s>", self.class.to_s, self.object_id, self.request.method, self.request.url)
        end
      end
    end
  end
end
