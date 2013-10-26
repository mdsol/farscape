module Farscape
  ##
  # Returns the configuration singleton.
  # 
  # @return [Farscape::Configuration::Base] The configuration instance.
  def self.config
    @config ||= Configuration::Base.new
  end
  
  ##
  # Configures Farscape by executing an associated block.
  # 
  # @example
  #   Farscape.configure do
  #
  #   end
  #   
  # @see Farscape::Configuration::Base See Configuration::Base for more information on configuration.
  def self.configure(&block)
    class_eval(&block)
  end
  
  module Configuration
    # Manages the configuration of Farscape.
    class Base
      
      def initialize
        reset
      end
  
      # Clears any prior configurations. Mainly utility method for specs since class ivars do not reset between
      # specs.
      def reset
        # Reset ivars
      end
    end
  end
end
