require 'farscape/configuration'

module Farscape
  module Helpers
    def config
      Farscape::Configuration.config
    end
    
    def client_factory
      config.client_factory
    end
  end
end
