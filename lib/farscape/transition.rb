require 'representors'
require 'ostruct'

module Farscape

  class TransitionAgent

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

      @agent.find_exception(response)
    end

    def method_missing(meth, *args, &block)
      @transition.send(meth, *args, &block)
    end

    private

    def match_params(args, options)
      [:parameters, :attributes].each do |key_type|
        field_list = @transition.public_send(key_type)
        field_names = field_list.map { |field| field.name.to_sym }
        filtered_values = args.select { |k,_| field_names.include?(k) }
        values = filtered_values.merge(options.public_send(key_type) || {})
        options.public_send(:"#{key_type}=", values)
      end
      options
    end


  end
end
