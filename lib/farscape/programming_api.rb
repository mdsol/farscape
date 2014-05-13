
module Farscape

  # This is the external API for the users of farscape.
  # It is supposed to be more constraint but very straight-forward to use.
  class << self
    # Returns the configuration of the Farscape functionality
    def config
      @config ||= ConfigFile.new.configuration
    end

    # Gets and resturns the respresentation as an object of some url which should have a document
    # @param [String] URL
    def get(url, options={})
      SimpleAgent.get(url, options)
    end

  end

end