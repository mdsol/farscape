require 'representors'
require 'farscape/transition'
require 'ostruct'

module Farscape
  class SafeRepresentorAgent
    attr_reader :agent
    attr_reader :representor
    attr_reader :response

    EMPTY_BODIES = { hale: "{}" } #TODO: Fix Representor to allow nil resources

    def initialize(requested_media_type, response, agent)
      @agent = agent
      @response = response
      @requested_media_type = requested_media_type
      @representor = deserialize(requested_media_type, response.body)
      handle_extensions
    end

    def handle_extensions
      extensions = Plugins.extensions(enabled_plugins)
      extensions = extensions[self.class.to_s.split(':')[-1].to_sym]
      extensions.map { |cls| self.extend(cls) } if extensions
    end
    
    %w(using omitting).each do |meth|
      define_method(meth) { |name_or_type| self.class.new(@requested_media_type, @response, @agent.send(meth, name_or_type)) }
    end

    %w(disabled_plugins enabled_plugins plugins).each do |meth|
      define_method(meth) { @agent.send(meth) }
    end

    def attributes
      representor.properties
    end

    #TODO: Handling list of transitions
    def transitions
      Hash[representor.transitions.map{ |trans| [trans.rel, Farscape::TransitionAgent.new(trans, agent)] }]
    end

    def embedded
      Hash[representor.embedded.map{ |k, reps| [k, _embedded(reps, response)] }]
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

    def reframe_representor(safety)
      agent = safety ? @agent.safe : @agent.unsafe
      agent.representor.new(@requested_media_type, @response, agent)
    end

    def deserialize(requested_media_type, response_body)
      return response_body unless requested_media_type
      response_body = response_body || EMPTY_BODIES[@agent.media_type]
      Representors::DeserializerFactory.build(requested_media_type, response_body).to_representor
    end

    def _embedded(reprs, response)
      reprs.map { |repr| @agent.representor.new(false, OpenStruct.new(status: response.status, headers: response.headers, body: repr), @agent) }
    end

  end

  class RepresentorAgent < SafeRepresentorAgent
    def method_missing(method, *args, &block)
      super
    rescue NoMethodError => e
      parameters = args.first || {}
      get_embedded(method) || get_transition(method, parameters, &block) || get_attribute(method) || raise
    end

    def respond_to_missing?(method_name, include_private = false)
      super || [embedded.include?(method_name), method_transitions.include?(method), attributes.include?(method)].any?
    end

    # HACK! - Requires for method_missing; apparently an undocumented feature of Ruby
    def to_ary
    end

    private

    def get_embedded(meth)
      embedded[meth.to_s]
    end

    def get_attribute(meth)
      attributes[meth.to_s]
    end

    def get_transition(meth, request_params = {}, &block)
      return false unless method_transitions.include?(meth = meth.to_s)
      block = ->(*args) { args } unless block_given?
      method_transitions[meth].invoke(request_params) { |x| block.call(x) }
    end

    def method_transitions
      transitions.map { |k,v| @agent.client.safe_method?( v.interface_method ) ? {k => v}  : {k+'!' => v} }.reduce({}, :merge)
    end

  end
end
