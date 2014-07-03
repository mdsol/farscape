
module Farscape
  # General response errors, this class provides access to the raw response
  class ResponseError < StandardError
    attr_reader :response
    def initialize(response)
      @response = response
    end
  end
end