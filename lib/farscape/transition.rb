require 'representors'
require 'ostruct'
require 'active_support/core_ext/object/blank'

module Farscape

  class TransitionAgent

    include BaseAgent

    def initialize(transition, agent)
      @agent = agent
      @transition = transition
      handle_extensions
    end

    def invoke(args = {})
      opts = OpenStruct.new
      yield opts if block_given?
      options = match_params(args, opts)
      params = args.merge(options.parameters || {})

      call_options = {}
      call_options[:method] = @transition.interface_method
      call_options[:headers] = @agent.get_accept_header(@agent.media_type).merge(options.headers || {})
      call_options[:body] = options.attributes if options.attributes.present?

      if call_options[:method].downcase == 'get'
        # delegate the URL building to representors so we can use templated URIs

        # We are in another unfortunate situation in which Mauth-client might not be able to validate
        # if a request query string contains uppercase characters.
        # Somebody, probably Nginx, converts the query string to lowercase, and Mauth-client uses it
        # to compare with the signature which is generated using the original query string.
        # https://github.com/mdsol/mauth-client-ruby/blob/v4.0.1/lib/mauth/client.rb#L333
        call_options[:url] = @transition.uri(params).downcase
        # still need to use this for extra params... (e.g. "conditions=can_do_anything")
        if params.present?
          if @transition.templated?
            # exclude the parameters that have been consumed by Addressable (e.g. path segments) so
            # we don't repeat those in the final URL (ex: /api{/uuid} => /api/123456, not /api/123456?uuid=123456)
            # TODO: make some "variables" method in representors/transition.rb so we don't deal with this here
            Addressable::Template.new(@transition.templated_uri).variables.each do |param|
              params.delete(param.to_sym)
            end
          end
          call_options[:params] = params
        end
      else
        # Farscape handles "parameters" as query string, and "attributes" as request body.
        # However, in many API documents, only "parameters" is used regardless of methods.
        # Since changing API documents must have a huge impact on existing systems,
        # we use parameters as the request body if the method is not GET.
        # This makes it impossible to use URIs with parameters.
        call_options[:url] = @transition.uri
        call_options[:body] = (call_options[:body] || {}).merge(params) if params.present?
      end

      response = @agent.client.invoke(call_options)

      @agent.find_exception(response)
    end

    %w(using omitting).each do |meth|
      define_method(meth) { |name_or_type| self.class.new(@transition, @agent.send(meth, name_or_type)) }
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
