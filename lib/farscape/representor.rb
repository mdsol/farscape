module Farscape

  # This is the main class the user of this library is gonna use to interact with the data
  # The data itself is accessed via @representor. The other methods are added by farscape
  # to it provides an easy to use API.
  # study.invoke('lock') should give back a new representor that can be acted upon or read data from
  class Representor < BasicObject
    # @param [Representors::representor] representor_data
    # It takes a representor from the Representors gem and decorate
    # it with several methods that made it convenient to invoke its
    # transitions
    # @param [Result] result , the result of a agent connection.
    def initialize(representor_data, result)
      @representor = representor_data
      @result = result
    end


    # Main method for the users of this library to get the next piece of data from a service
    # or to send data to a service
    # @param [String] link_name. The link_name to follow
    # @param [Hash] data_as_a_hash This is the data we want to provide if we are sending data
    def invoke(link_name, data_as_a_hash = nil)
      # TODO: what if there are more than one link with the same rel?
      link = @representor.transitions.select{|t| t.rel == link_name}.first
      if link.nil?
        raise UnknownTransition, "There was no link found for #{link_name} in #{@representor}"
      end
      Transition.new(link).invoke(data_as_a_hash)
    end

    # We are decorating Representor::Transition with Farscape::Transition so they can be invoked
    # @return [Array] of Farscape::Transition
    def transitions
      super().map {|transition_data| Transition.new(transition_data)}
    end

    # This provides:
    # agent.headers
    # agent.status
    # agent.body  (raw response)
    # agent.request
    # agent.response
    def agent
      @result
    end

    # So we tell properly who we are and do not get users confused
    def class
      Representor
    end

    # So we tell properly who we are and do not get users confused
    def instance_of?(class_name)
      if class_name == Representor
        true
      else
        false
      end
    end

    # Any method called in this object, delegate it to the representor with the data
    # so this works object.transitions
    def method_missing(method, *args, &block)
      @representor.send(method, *args, &block)
    end

  end
end