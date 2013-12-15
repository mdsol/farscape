require 'active_support/all'
require 'farscape/dice_bag/template'
require 'farscape/agent/client_factory'
require 'farscape/configuration/base'

module Farscape
  ##
  # Returns the configuration singleton.
  # 
  # @return [Farscape::Configuration::Base] The configuration instance.
  def self.config
    @config ||= Configuration::Base.new(Agent::ClientFactory)
  end

  ##
  # Configures Farscape by executing an associated block.
  # 
  # @example
  #   Farscape.configure do
  #     config.defaults do |builder|
  #       builder.use :some_middleware
  #     end
  #    
  #     client(:http, :https) do |builder|
  #       builder.use :http_middleware
  #     end
  #
  #     client(:tcp) do |builder|
  #       builder.use :tcp_middleware
  #     end
  #   end
  #   
  # @see Farscape::Configuration::Base See Configuration::Base for more information on configuration.
  def self.configure(&block)
    class_eval(&block)
  end

  private
  def self.reset_config
    @config = nil
  end
end
