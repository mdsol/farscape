require 'representors'
require 'farscape/transition'

module Farscape
  class Representor
    attr_reader :agent
    attr_reader :representor

    def initialize(requested_media_type, response_body, agent)
      @agent = agent
      @representor = Representors::DeserializerFactory.build(requested_media_type, response_body).to_representor
    end

    def attributes
      representor.properties
    end

    def transitions
      Hash[representor.transitions.map{ |trans| [trans.rel, Farscape::Transition.new(trans.to_hash, agent)]}]
    end

    def to_hash
      @representor.to_hash
    end
  end
end
