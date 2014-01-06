require 'farscape/agent/base_client'

module Farscape
  class Agent
    class HTTPClient < BaseClient
      schemes :http, :https
      
      private
      def default_adapter
        :net_http
      end
    end
  end
end
