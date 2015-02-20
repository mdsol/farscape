require 'farscape/representor'
require 'farscape/clients'

module Farscape
  class Agent
    PROTOCOL = :http

    attr_reader :media_type
    attr_reader :entry_point
    attr_reader :local_plugins

    def initialize(entry = nil, media = :hale, safe = false, local_plugins = {})
      @entry_point = entry
      @media_type = media
      @safe_mode = safe
      @local_plugins = local_plugins
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
      self.class.new(@entry_point, @media_type, true)
    end

    def unsafe
      self.class.new(@entry_point, @media_type, false)
    end

    def safe?
      @safe_mode
    end

    def using(name_or_type)
      names = Farscape.find_attr_intersect(Farscape.plugins, Farscape.normalize_selector(name_or_type))
      local_plugins = names.reduce(@local_plugins) { |h, k| h.merge({ k => Farscape.plugins[k] }) }
      self.class.new(@entry_point, @media, @safe_mode, local_plugins)
    end
    
    def middleware_stack
      Farscape.middleware_stack(@local_plugins)
    end

  end
end
