require 'farscape/agent/base_client'

module Farscape
  class Agent
    class HTTPClient < BaseClient
      schemes :http, :https
    end
  end
end
