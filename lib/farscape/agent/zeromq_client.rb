require 'farscape/agent/base_client'
require 'ffi-rzmq'
require 'faraday-zeromq'

module Farscape
  class Agent
    class ZeromqClient < BaseClient
      schemes :tcp
      
      private
      def default_adapter
        :zeromq
      end
      
      def transmit_connection(request)
        request.connection || Faraday.new(builder: connection_builder(request)) 
      end
      
      def connection_builder(request)
        context = ZMQ::Context.new
        socket = context.socket(ZMQ::REQ).tap { |s| s.connect(request.origin) }
        
        connection.builder.dup.tap do |builder|
          builder.handlers.pop #remove adapter
          builder.adapter default_adapter, socket, YAML # TODO: look at different serializer options
        end
      end
    end
  end
end
