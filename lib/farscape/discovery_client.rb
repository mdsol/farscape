module Farscape

  # This class would need to change when we design how the discovery service will look like
  # This is only a prototype and a testBench
  # TODO: rewrite when we figure out how to discover stuff, move it where it shoudl go
  class DiscoveryClient
    #returns nil if not discovered
    def discover(resource, options)
      discoverable_resource_item = all_billboard_resources.select do |registered_resource|
        registered_resource['href'].include?(resource)
      end.first
      if discoverable_resource_item
        href = discoverable_resource_item['href']
        discoverable_resource = SimpleAgent.get(href)
        entry_point = discoverable_resource.entry_point
        SimpleAgent.get(entry_point, options)
      end
    end

    def all_billboard_resources
      url = Farscape.config[:discovery_service_url]
      if url
        billboard = SimpleAgent.get(url)
        billboard.links.items
      else
        #TODO: log instead
        puts "Discovery of resources is not available. Add a #{CONFIGURATION_FILE_PATH} file
              with discoverable_service_url: URL where URL should provide items with links
              to resources."
        []
      end
    rescue NoMethodError
      []
    end

  end
end
