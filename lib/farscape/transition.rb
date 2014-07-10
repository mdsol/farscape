module Farscape

  # This is the main class the user of this library is gonna use to interact with the data
  # The data itself is accessed via @representor. The other methods are added by farscape
  # to it provides an easy to use API.
  # study.invoke('lock') should give back a new representor that can be acted upon or read data from
  class Transition < BasicObject
    # @param [Representors::representor] representor_data
    # It takes a representor from the Representors gem and decorate
    # it with several methods that made it convenient to invoke its
    # transitions
    # @param [Result] result , the result of a agent connection.
    def initialize(transition_data)
      @transition = transition_data
    end


    # Main method for the users of this library to get the next piece of data from a service
    # or to send data to a service
    # @param [String] link_name. The link_name to follow
    # @param [Hash] data_as_a_hash This is the data we want to provide if we are sending data
    def invoke(data_as_a_hash = nil)
      if data_as_a_hash
        body = data_as_a_hash.to_json
        # If the link does not provide a proper method, that is a bug in the reprensation we got
        SimpleAgent.invoke(uri, {method: interface_method, body: body })
      else
        SimpleAgent.invoke(uri, {method: interface_method })
      end
    end


    # So we tell properly who we are and do not get users confused
    def class
      Transition
    end

    # So we tell properly who we are and do not get users confused
    def instance_of?(class_name)
      if class_name == Transition
        true
      else
        false
      end
    end

    # Any method called in this object, delegate it to the representor with the data
    # so this works object.transitions
    def method_missing(method, *args, &block)
      @transition.send(method, *args, &block)
    end

  end
end