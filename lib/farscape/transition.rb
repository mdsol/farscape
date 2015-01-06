require 'representors'
require 'ostruct'

module Farscape
  class TransitionAgent

    EMPTY_BODIES = { hale: "{}" } #TODO: Fix Representor to allow nil resources

    def initialize(transition, agent)
      @agent = agent
      @transition = transition
    end

    def invoke(*args)
      options = OpenStruct.new
      yield options if block_given?

      match_params(args)

      call_options = {}
      call_options[:url] = uri
      call_options[:method] = interface_method
      call_options[:headers] = @agent.get_accept_header(@agent.media_type).merge(options.headers || {})
      call_options[:params] = options.parameters if options.parameters
      call_options[:body] = options.attributes if options.attributes

      response = @agent.client.invoke(call_options)
      @agent.representor.new(@agent.media_type, response.body || EMPTY_BODIES[@agent.media_type], @agent)
    end

    def method_missing(meth, *args, &block)
      @transition.send(meth, *args, &block)
    end

    def match_params(args)
      print @transition
      print "\np=", @transition.parameters
      print "\na=", @transition.attributes
    end
  end
end
