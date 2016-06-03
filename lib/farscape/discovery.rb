module Farscape
  # This class provide discovery capabilities to Farscape.
  class Discovery

    DISCOVERY_KEY = :discovery_uri

    class NotFound < NameError
    end

    # This is the simplest type of discovery. We assume that the url we will call will provide us
    # document with links which keys are the names we want to discover and hrefs are root URLS.
    # Templated URLs are supported, an exception will be raised if the template does not match the variables.
    #       {
    #        "_links": {
    #          "boxes": { "href": "https://smallboxesandpoliceboxes.com" },
    #          "items": { "href": "https://sonicscrewdriversandotherthings.com/v1/{item}" }
    #        }
    #      }
    def discover(config, key, url_template_variables)
      discovery_uri = config[DISCOVERY_KEY]
      raise NotFound, "No discovery uri setup for Farscape. Discovery of #{key} unavailable" unless discovery_uri
      raise NotFound, "Discover URL #{discovery_uri} is not a valid URL." unless discovery_uri =~ URI::regexp
      discovery_document = Farscape::Agent.new(discovery_uri).enter
      if discovery_document.kind_of?(Faraday::Response) # Parse errors give us a raw Faraday Response
        raise NotFound, "The discovery document for #{key} is not valid JSON. We got: #{discovery_document.body}"
      end
      found = discovery_document.transitions[key.to_s]
      raise NotFound, "No key '#{key}' found in the response from the discovery service." unless found
      found.uri(url_template_variables)
    end
  end
end
