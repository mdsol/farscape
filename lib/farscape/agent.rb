require 'farscape/representor'
require 'farscape/clients'

module Farscape
  class Agent
    PROTOCOL = :http

    attr_reader :media_type
    attr_reader :entry_point

    def initialize(entry = nil, media = :hale, safe = false)
      @entry_point = entry
      @media_type = media
      @safe_mode = safe
    end

    def representor
      safe? ? SafeRepresentorAgent : RepresentorAgent
    end

    def enter(entry = entry_point)
      @entry_point ||= entry
      raise "No Entry Point Provided!" unless entry
      response = client.invoke(url: entry, headers: get_accept_header(media_type))
      representor.new(media_type, response.body, self)
    end

    # TODO share this information with serialization factory base
    def get_accept_header(media_type)
      media_types = { hale: 'application/vnd.hale+json' }
      { 'Accept' => media_types[media_type] }
    end

    def client
      Farscape.clients[PROTOCOL].new
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

  end
end
