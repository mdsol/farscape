require_relative 'config_file'

module Farscape

  class DiscoveryClient
    #returns nil if not discovered
    def discover(resource)
      url = Farscape.config[:discovery_service_url]
      if url
        billboard = SimpleAgent.get(url)
        all_registered_resources = billboard.links.items
        discoverable_resource_item = all_registered_resources.select do |registered_resource|
          registered_resource['href'].include?(resource)
        end.first
        if discoverable_resource_item
          href = discoverable_resource_item['href']
          discoverable_resource = SimpleAgent.get(href)
          entry_point = discoverable_resource.entry_point
          SimpleAgent.get(entry_point)
        end
      else
        #TODO: log instead
        puts "Discovery of resources is not available. Add a #{CONFIGURATION_FILE_PATH} file
              with discoverable_service_url: service_url where URL should provide items with links
              to resources."
      end
    end
  end

  class SimpleAgent
    def self.get(url, options={})
      options.merge!({method: 'GET'})
      SimpleAgent.new.perform_request(url, options)
    end

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
      response.body
    end
  end


  #This is the external interface for the users of farscape
  class << self
    def config
      @config ||= ConfigFile.new.configuration
    end

    def discover(resource_name)
      DiscoveryClient.new.discover(resource_name)
    end

    def get(url, options={})
      SimpleAgent.get(url, options)
    end

  end

end