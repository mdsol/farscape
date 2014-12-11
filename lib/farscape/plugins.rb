require_relative 'helpers/partially_ordered_list'

module Farscape

  @plugins = []
  @disabled_plugins = []
  @middleware_stack = PartiallyOrderedList.new { |m,n| order_middleware(m,n) }

  class <<self

    attr_reader :plugins
    attr_reader :disabled_plugins
    attr_reader :middleware_stack

    def register_plugin(options)
      return false if disabled?(options)
      @plugins << options
      add_middleware(options)
      true
    end

    # If the middleware has been disabled by name, return the name
    # Else if by type, return the type.
    def disabled?(options)
      (disabled_plugins & [options[:name],options[:type]]).first
    end

    def disable(name_or_type)
      disabled_plugins << name_or_type
      plugins_to_disable, @plugins = @plugins.partition { |plugin| [plugin[:name], plugin[:type]].include?(name_or_type) }
      plugins_to_disable.each { |plugin| disable_plugin(plugin) }
    end

    private

    def disable_plugin(plugin)
      @middleware_stack.select{ |m| m[:plugin] == plugin[:name] }.each { |m| @middleware_stack.delete(m) }
    end

    def add_middleware(options)
      [*options[:middleware]].each do |middleware|
        if middleware.is_a?(Hash)
          middleware[:type] = options[:type]
          middleware[:plugin] = options[:name]
        else
          middleware = {class: middleware, type: options[:type], plugin: options[:plugin]}
        end
        @middleware_stack.add(middleware)
      end
    end

    def order_middleware(mw_1, mw_2)
      case
      when includes_middleware(mw_1[:before],mw_2)
        -1
      when includes_middleware(mw_1[:after],mw_2)
        1
      when includes_middleware(mw_2[:before],mw_1)
        1
      when includes_middleware(mw_2[:after],mw_1)
        -1
      end
    end

    def includes_middleware?(list, middleware)
      list = [*list]
      list.map(&:to_s).include?(middleware[:class].to_s) || list.include?(middleware[:type])
    end

  end

end
