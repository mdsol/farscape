require 'representors'
require 'farscape/transition'

module Farscape
  class SafeRepresentorAgent
    attr_reader :agent
    attr_reader :representor

    # TODO: Work with Representor to make this straight forwqrd.
    # The conditional is to allow direct creation of a RepresentorAgent from a Representor
    def initialize(requested_media_type, response_body, agent)
      @agent = agent
      @representor = requested_media_type ? deserialize(requested_media_type, response_body) : response_body
    end

    def attributes
      representor.properties
    end

    #TODO: Handling list of transitions
    def transitions
      Hash[representor.transitions.map{ |trans| [trans.rel, Farscape::TransitionAgent.new(trans, agent)] }]
    end

    def embedded
      Hash[representor.embedded.map{ |k, reps| [k, reps.map { |rep| @agent.representor.new(false, rep, agent) }] }]
    end

    def to_hash
      @representor.to_hash
    end

    def method_missing(method, *args, &block)
      super
    end

    def safe
      reframe_representor(safe=true)
    end

    def unsafe
      reframe_representor(safe=false)
    end

    private

    def reframe_representor(safe)
      agent = safe ? @agent.safe : @agent.unsafe
      agent.representor.new(nil, @representor, agent)
    end

    def deserialize(requested_media_type, response_body)
      Representors::DeserializerFactory.build(requested_media_type, response_body).to_representor
    end

  end

  class RepresentorAgent < SafeRepresentorAgent
    def method_missing(method, *args, &block)
      print method
      method = method.to_s

      get_embedded(method) || get_transition(method, *args, &block) || get_attribute(method) || super(method, *args, &block)
    end

    def respond_to_missing?(method_name, include_private = false)
      [embedded.include?(method_name), method_transitions.include?(method), attributes.include?(method)].any? || super
    end

    private

    def get_embedded(meth)
      print "\n==============================\n"
      print embedded.keys, meth
      print "\n==============================\n"
      embedded[meth]
    end

    def get_transition(meth, request_params = nil, &block)
      print method_transitions.keys, meth
      return false unless method_transitions.include?(meth)
      if request_params
        method_transitions[meth].invoke(request_params) { block }
      else
        block_given? ? method_transitions[meth].invoke { |req| req.parameters = request_params } : method_transitions[meth].invoke { block }
      end
    end

    def get_attribute(meth)
      attributes[meth]
    end

    def method_transitions
      transitions.map { |k,v| @agent.client.safe_method?( v.interface_method ) ? {k => v}  : {k+'!' => v} }.reduce(:merge)
    end

  end
end
