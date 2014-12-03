require 'farscape/representor'
require 'farscape/client/http_client'

module Farscape
  class Agent
    PROTOCOL = :http

    attr_reader :media_type
    attr_reader :entry_point

    def initialize(entry = nil, media = :hale)
      @entry_point = entry
      @media_type = media
    end

    def enter(entry = entry_point)
      @entry_point ||= entry
      raise "No Entry Point Provided!" unless entry
      response = client.invoke(url: entry, headers: get_accept_header(media_type))
      Representor.new(media_type, response.body, self)
    end

    # TODO share this information with serialization factory base
    def get_accept_header(media_type)
      media_types = { hale: 'application/vnd.hale+json' }
      { 'Accept' => media_types[media_type] }
    end

    def client
      { http: HTTPClient }[PROTOCOL].new
    end
  end
end
