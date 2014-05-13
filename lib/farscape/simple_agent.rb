module Farscape
# An Agent that uses the lower lever and more complex to use Farscape Agent to perform requests
# It gives back results using the crichton-representor gem, thus returns objects for the
# User to interact with the data instead of the data itself.
# It also uses the configuration config/faraday.yml
# In short it is easier to use and it is more integrated with our tools.
  class SimpleAgent
    # Convenience method to DRY adding get to the options
    def self.get(url, options={})
      options.merge!({method: 'GET'})
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
      deserializer = Crichton::Deserializer.create(response.headers['Content-Type'], response.body)
      deserializer.deserialize
    rescue Crichton::UnknownFormatError
      Crichton::Golem.new #TODO: do not show this object class here
    end
  end

end
