require 'farscape/representor'
require 'farscape/clients'

module Farscape
  class Agent
    PROTOCOL = :http

    attr_reader :media_type
    attr_reader :entry_point
    
    def initialize(entry = nil, media = :hale, safe = false, pluginhash = {})
      @entry_point = entry
      @media_type = media
      @safe_mode = safe
      @pluginhash = pluginhash.empty? ? default_plugin_hash : pluginhash
    end

    def representor
      safe? ? SafeRepresentorAgent : RepresentorAgent
    end

    def enter(entry = entry_point)
      @entry_point ||= entry
      raise "No Entry Point Provided!" unless entry
      response = client.invoke(url: entry, headers: get_accept_header(media_type))
      find_exception(response)
    end

    def find_exception(response)
      error = client.dispatch_error(response)
      begin
        representing = representor.new(media_type, response, self)
      rescue JSON::ParserError
        representing = response
      end
      raise error.new(representing) if error
      representing
    end

    # TODO share this information with serialization factory base
    def get_accept_header(media_type)
      media_types = { hale: 'application/vnd.hale+json' }
      { 'Accept' => media_types[media_type] }
    end

    def client
      Farscape.clients[PROTOCOL].new(self)
    end

    def safe
      self.class.new(@entry_point, @media_type, true, @pluginhash)
    end

    def unsafe
      self.class.new(@entry_point, @media_type, false, @pluginhash)
    end

    def safe?
      @safe_mode
    end

    def enabled_plugins
      Plugins.enabled_plugins(@pluginhash[:plugins])
    end

    def middleware_stack
      @pluginhash[:middleware_stack] ||= Plugins.construct_stack(enabled_plugins)
    end

    def using(name_or_type)
      disabling_rules, plugins = Plugins.enable(name_or_type, @pluginhash[:disabling_rules], @pluginhash[:plugins])
      plugin_hash = {
        disabling_rules: disabling_rules,
        plugins: plugins,
        middleware_stack: nil
      }
      self.class.new(@entry_point, @media_type, @safe_mode, plugin_hash)
    end

    private
    
    def default_plugin_hash
      {
        plugins: Farscape.plugins.dup,
        disabling_rules: Farscape.disabling_rules.dup,
        middleware_stack: nil
      }
    end
    
  end
end
