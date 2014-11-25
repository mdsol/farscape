require 'representors'

module Farscape
  class Transition < Representors::Transition

    def initialize(transition_hash, agent)
      @agent = agent
      super(transition_hash)
    end

    def invoke
      response = @agent.client.invoke({url: uri, method: interface_method, headers: @agent.get_accept_header(@agent.media_type)})
      Representor.new(@agent.media_type, response.body, @agent)
    end
  end
end