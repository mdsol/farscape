require 'representors'
require 'farscape/transition'

module Farscape
  class Representor
    attr_reader :agent
    attr_reader :representor

    # TODO: Work with Representor to make this straight forwqrd.
    def initialize(requested_media_type, response_body, agent)
      @agent = agent
      if requested_media_type
        @representor = Representors::DeserializerFactory.build(requested_media_type, response_body).to_representor
      else
        @representor = response_body
      end
    end

    def attributes
      representor.properties
    end

    def transitions
      Hash[representor.transitions.map{ |trans| [trans.rel, Farscape::Transition.new(trans, agent)]}]
    end
    
    def embedded
      Hash[representor.embedded.map do |k, reps| 
           [k, reps.map { |rep| Representor.new(false, rep, agent) }]
      end]
    end

    def to_hash
      @representor.to_hash
    end
  end
end
