require_relative 'helpers/partially_ordered_list'

module Farscape

  @plugins = {}
  @disabling_rules = []
  @_middleware_stack = nil

  class <<self

    attr_reader :plugins
    attr_reader :disabling_rules

    def register_plugin(options)
      @middleware_stack = nil
      options[:enabled] = enabled?(options)
      @plugins[options[:name]] = options
    end

    def register_plugins(a_list)
      a_list.each { |options| register_plugin(options) }
    end

    def enabled_plugins
      @plugins.select { |plugin| @plugins[plugin][:enabled] }
    end

    def disabled_plugins
      @plugins.reject { |plugin| @plugins[plugin][:enabled] }
    end

    # If the middleware has been disabled by name, return the name
    # Else if by type, return the type.
    # Else if :default_state was passed in return :default_state
    def why_disabled(options)
      maybe = @disabling_rules.map { |hash| hash.select { |k,v| k if v == options[k] } }
      maybe |= disabled_plugins.map { |k,v| v[:name] }
      maybe |= [:default_state] if options[:default_state] == :disabled
      maybe
    end
    
    def disabled?(options)
      options = normalize_selector(options)
      return @plugins[options[:name]][:enabled] if options.include?([:name])
      why_disabled(options).any?
    end
    
    def enabled?(options)
      !disabled?(options)
    end

    # Prevents a plugin from being registered, and disables it if it's already there
    def disable!(name_or_type)
      @middleware_stack = nil
      name_or_type = normalize_selector(name_or_type)
      @disabling_rules << name_or_type
      set_plugin_states(name_or_type, false)
    end

    # Allows a plugin to be registered, and enables it if it's already there
    def enable!(name_or_type)
      @middleware_stack = nil
      name_or_type = normalize_selector(name_or_type)
      @disabling_rules.delete(name_or_type)
      set_plugin_states(name_or_type, true)
    end

    # Returns the Poset representing middleware dependency
    def middleware_stack
      @middleware_stack ||= construct_stack(enabled_plugins)
    end
    
    # Removes all plugins and disablings of plugins
    def clear
      @plugins = {}
      @disabling_rules = []
      @middleware_stack = nil
    end

    private

    def set_plugin_states(name_or_type, condition)
      selected_plugins = find_attr_intersect(@plugins, name_or_type)
      selected_plugins.each { |plugin| @plugins[plugin][:enabled] = condition }
    end

    def construct_stack(plugins)
      stack = PartiallyOrderedList.new { |m,n| order_middleware(m,n) }
      plugins.map do |_, plugin|
        [*plugin[:middleware]].map do |middleware|
          middleware = {class: middleware} unless middleware.is_a?(Hash)
          middleware[:type] = plugin[:type]
          middleware[:plugin] = plugin[:name]
          stack.add(middleware)
        end
      end
      stack
    end

    def normalize_selector(name_or_type)
      name_or_type.is_a?(Hash) ? name_or_type : { name: name_or_type, type: name_or_type}
    end

    # Used by PartiallyOrderedList to implement the before: and after: options
    def order_middleware(mw_1, mw_2)
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

    def find_attr_intersect(master_hash, selector_hash)
      master_hash.map do |mkey, mval|
        selector_hash.map { |skey, sval| mkey if mval[skey] == sval }
      end.flatten.compact
    end

    # Search a list for a given middleware by either its class or the type of its originating plugin
    def includes_middleware?(list, middleware)
      list = [*list]
      list.map(&:to_s).include?(middleware[:class].to_s) || list.include?(middleware[:type])
    end

  end

end
