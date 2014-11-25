require 'farscape/representor'
require 'farscape/agent/http_client'

module Farscape
  class Agent
    PROTOCOL = :http

    attr_reader :media_type
    attr_reader :entry_point

    def initialize(entry = nil, media = :hale)
      @entry_point = entry
      @media_type = media
    end

    def enter(entry = nil)
      @entry_point ||= entry
      url = entry || entry_point
      raise "No Entry Point Provided!" unless url

      response = client.invoke(url: url, headers: get_accept_header(media_type))
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
