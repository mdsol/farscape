module Farscape
  module BaseAgent
    
    def handle_extensions
      extensions = Plugins.extensions(enabled_plugins)
      extensions = extensions[self.class.to_s.split(':')[-1].to_sym]
      extensions.each { |cls| self.extend(cls) } if extensions
    end

    %w(disabled_plugins enabled_plugins plugins).each do |meth|
      define_method(meth) { @agent.send(meth) }
    end
    
  end
end
