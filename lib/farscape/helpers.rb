require 'farscape/configuration'

module Farscape
  module Helpers
    def config
      Farscape::Configuration.config
    end
  end
end
