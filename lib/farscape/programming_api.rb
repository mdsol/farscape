
module Farscape

  #This is the external API for the users of farscape.
  class << self
    # Returns the configuration of the Farscape functionality
    def config
      @config ||= ConfigFile.new.configuration
    end

    # Discovers and returns the representation as an object of the entry point of a resource
    # @param [String] resource_name : resource name to discover.
    def discover(resource_name, options = {})
      DiscoveryClient.new.discover(resource_name, options)
    end

    # Gets and resturns the respresentation as an object of some url which should have a document
    # @param [String] URL
    def get(url, options={})
      SimpleAgent.get(url, options)
    end

  end

end