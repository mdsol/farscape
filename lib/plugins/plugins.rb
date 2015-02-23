module Farscape
  module Plugins

    def self.enabled_plugins(plugins)
      plugins.select { |plugin| plugins[plugin][:enabled] }
    end

    def self.disabled_plugins(plugins)
      plugins.reject { |plugin| plugins[plugin][:enabled] }
    end

    # If the middleware has been disabled by name, return the name
    # Else if by type, return the type.
    # Else if :default_state was passed in return :default_state
    def self.why_disabled(plugins, disabling_rules, options)
      maybe = disabling_rules.map { |hash| hash.select { |k,v| k if v == options[k] } }
      maybe |= [disabled_plugins(plugins)[options[:name]]]
      maybe |= [:default_state] if options[:default_state] == :disabled
      maybe.compact
    end
    
    def self.disabled?(plugins, disabling_rules, options)
      options = normalize_selector(options)
      return plugins[options[:name]][:enabled] if options.include?([:name])
      why_disabled(plugins, disabling_rules, options).any?
    end
    
    def self.enabled?(plugins, disabling_rules, options)
      !self.disabled?(plugins, disabling_rules, options)
    end

    def self.disable(name_or_type, disabling_rules, plugins)
      name_or_type = self.normalize_selector(name_or_type)
      plugins = set_plugin_states(name_or_type, false, plugins)
      [disabling_rules << name_or_type, plugins]      
    end

    def self.enable(name_or_type, disabling_rules, plugins)
      name_or_type = normalize_selector(name_or_type)
      plugins = set_plugin_states(name_or_type, true, plugins)
      [disabling_rules.reject {|k| k == name_or_type}, plugins]      
    end

    def self.set_plugin_states(name_or_type, condition, plugins)
      plugins = Marshal.load( Marshal.dump(plugins) ) # TODO: This is super inefficient, figure out a good deep_dup
      selected_plugins = find_attr_intersect(plugins, name_or_type)
      selected_plugins.each { |plugin| plugins[plugin][:enabled] = condition }
      plugins
    end

    def self.construct_stack(plugins)
      stack = PartiallyOrderedList.new { |m,n| order_middleware(m,n) }
      plugins.each do |_, plugin|
        [*plugin[:middleware]].each do |middleware|
          middleware = {class: middleware} unless middleware.is_a?(Hash)
          middleware[:type] = plugin[:type]
          middleware[:plugin] = plugin[:name]
          stack.add(middleware)
        end
      end
      stack
    end

    def self.normalize_selector(name_or_type)
      name_or_type.is_a?(Hash) ? name_or_type : { name: name_or_type, type: name_or_type}
    end

    # Used by PartiallyOrderedList to implement the before: and after: options
    def self.order_middleware(mw_1, mw_2)
      case
      when includes_middleware?(mw_1[:before],mw_2)
        -1
      when includes_middleware?(mw_1[:after],mw_2)
        1
      when includes_middleware?(mw_2[:before],mw_1)
        1
      when includes_middleware?(mw_2[:after],mw_1)
        -1
      end
    end

    def self.find_attr_intersect(master_hash, selector_hash)
      master_hash.map do |mkey, mval|
        selector_hash.map { |skey, sval| mkey if mval[skey] == sval }
      end.flatten.compact
    end

    # Search a list for a given middleware by either its class or the type of its originating plugin
    def self.includes_middleware?(list, middleware)
      list = [*list]
      list.map(&:to_s).include?(middleware[:class].to_s) || list.include?(middleware[:type])
    end

  end
end
