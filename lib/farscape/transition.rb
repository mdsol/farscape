require 'representors'
require 'ostruct'

module Farscape

  class TransitionAgent

    EMPTY_BODIES = { hale: "{}" } #TODO: Fix Representor to allow nil resources

    def initialize(transition, agent)
      @agent = agent
      @transition = transition
    end

    def invoke(args={})
      opts=OpenStruct.new
      yield opts if block_given?
      options = match_params(args, opts)

      call_options = {}
      call_options[:url] = @transition.uri
      call_options[:method] = @transition.interface_method
      call_options[:headers] = @agent.get_accept_header(@agent.media_type).merge(options.headers || {})
      call_options[:params] = options.parameters if options.parameters
      call_options[:body] = options.attributes if options.attributes

      response = @agent.client.invoke(call_options)
      @agent.representor.new(@agent.media_type, response.body || EMPTY_BODIES[@agent.media_type], @agent)
    end

    def method_missing(meth, *args, &block)
      @transition.send(meth, *args, &block)
    end

    private

    def match_params(args, options)
      hash_filter = ->(hash,list) { hash.select { |k,_| list.include?(k) } }
      field_names = ->(field_list) { field_list.map { |field| field.name.to_sym } }
            [:parameters, :attributes].each do |key_type|
              filtered_values = hash_filter.call(args, field_names.call(@transition.public_send(key_type)))
              options.public_send(:"#{key_type}=", filtered_values.merge(options.public_send(key_type) || {}))
            end
      # params = hash_filter.call(args, field_names.call(@transition.parameters))
      # attrs = hash_filter.call(args, field_names.call(@transition.attributes))
      # options.parameters = params.merge(options.parameters || {})
      # options.attributes = attrs.merge(options.attributes || {})

      options
    end
  end
end
