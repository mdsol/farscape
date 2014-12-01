require 'representors'
require 'ostruct'

module Farscape
  class Transition < Representors::Transition

    def initialize(transition_hash, agent)
      @agent = agent
      super(transition_hash)
    end

    def invoke
      options = OpenStruct.new
      yield options if block_given?

      call_options = {}
      call_options[:url] = uri
      call_options[:method] = interface_method
      call_options[:headers] = @agent.get_accept_header(@agent.media_type).merge(options.headers || {})
      call_options[:params] = options.parameters if options.parameters
      call_options[:body] = options.attributes if options.attributes

      response = @agent.client.invoke(call_options)
      Representor.new(@agent.media_type, response.body, @agent)
    end
  end
end
