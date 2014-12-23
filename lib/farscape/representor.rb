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
      method = method.to_s

      get_embedded(method) || get_transition(method, *args, &block) || get_attribute(method) || raise(NoMethodError)
    end

    private

    def get_embedded(method)
      embedded[method]
    end

    def get_transition(method, *args, &block)
      return false unless method_transitions.include?(method)
      args.empty? ? method_transitions[method].invoke(&block) : method_transitions[method].invoke { |req| req.parameters = args.first }
    end

    def get_attribute(method)
      attributes[method]
    end

    def method_transitions
      transitions.map { |k,v| @agent.client.safe_methods.include?( v.interface_method ) ? {k => v}  : {k+'!' => v} }.reduce(:merge)
    end

  end
end
