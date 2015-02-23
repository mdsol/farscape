require_relative 'helpers/partially_ordered_list'

module Farscape
  
    extend Plugins

    attr_reader :plugins
    attr_reader :disabling_rules

    @plugins = {}
    @disabling_rules = []
    @middleware_stack = nil
    
    def self.plugins
      @plugins
    end

    def self.disabling_rules
      @disabling_rules
    end
      
    def self.register_plugin(options)
      @middleware_stack = nil
      options[:enabled] = self.enabled?(options)
      @plugins[options[:name]] = options
    end

    def self.register_plugins(a_list)
      a_list.each { |options| register_plugin(options) }
    end

    # Returns the Poset representing middleware dependency
    def self.middleware_stack
      @middleware_stack ||= Plugins.construct_stack(enabled_plugins)
    end

    def self.enabled_plugins
      Plugins.enabled_plugins(@plugins)
    end

    def self.disabled_plugins
      Plugins.disabled_plugins(@plugins)
    end
    
    def self.disabled?(options)
      Plugins.disabled?(@plugins, @disabling_rules, options)
    end
    
    def self.enabled?(options)
      Plugins.enabled?(@plugins, @disabling_rules, options)
    end

    # Prevents a plugin from being registered, and disables it if it's already there
    def self.disable!(name_or_type)
      @middleware_stack = nil
      @disabling_rules, @plugins = Plugins.disable(name_or_type, @disabling_rules, @plugins)
    end

    # Allows a plugin to be registered, and enables it if it's already there
    def self.enable!(name_or_type)
      @middleware_stack = nil
      @disabling_rules, @plugins = Plugins.enable(name_or_type, @disabling_rules, @plugins)
    end
    
    # Removes all plugins and disablings of plugins
    def self.clear
      @plugins = {}
      @disabling_rules = []
      @middleware_stack = nil
    end
end
