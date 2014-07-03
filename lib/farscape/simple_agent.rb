module Farscape
# An Agent that uses the lower lever and more complex to use Farscape Agent to perform requests
# It gives back results using the crichton-representor gem, thus returns objects for the
# User to interact with the data instead of the data itself.
# It also uses the configuration config/faraday.yml
# In short it is easier to use and it is more integrated with our tools.
  class SimpleAgent
    # Convenience method to DRY adding get to the options
    def self.invoke(url, options={})
      SimpleAgent.new.perform_request(url, options)
    end

    # Performs a request using the configuration and returning an object.
    def perform_request(url, options={} )
      default_options = {
        url: url,
        method: 'GET',
        headers: { 'accept' => Farscape.config[:default_accept] }
      }
      options = default_options.merge!(options)
      agent = Agent.new
      response = agent.invoke(options)
      deserializer = Representors::Deserializer.build(response.headers['Content-Type'], response.body)

      Representor.new(deserializer.to_representor, response)
    rescue Representors::UnknownFormatError
      raise Farscape::ResponseError.new(response),
        "The content type #{response.headers['Content-Type']} can not be deserializer"
    end
  end

end
