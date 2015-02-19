require 'spec_helper'

module TestMiddleware
  class NoGetNoProblem
    def initialize(app, config = {})
      @app = app
      @config = config
    end
    def call(env)
      @app.call(env).on_complete do |env|
        unless @config[:permissive]
          raise StandardError, "Shazam!" if env[:method] == :get
        end
      end
    end
  end
 
  class Saboteur
    def initialize(app, *)
      @app = app
    end
    def call(env)
      env[:sabotaged] = true
      @app.call(env)
    end
  end

  class SabotageDetector
    def initialize(app, *)
      @app = app
    end
    def call(env)
      raise 'Sabotage detected' if env[:sabotaged]
      @app.call(env)
    end
  end

end




# Farscape Plugin Configuration Hash
# {
#   name: The Name of the Plugin
#   type: The type of plugin
#   middleware: A list of either objects of middleware hashes
#   extension: A list of objects
#   extends: A list of symbols referencing farscape objects 
#   default_state: :enabled or :disabled (defualts to :enabled)
# }

# Farscape.register_plugin # Registers the object and puts it in its default state 
# Farscape.plugins # A list of all plugins
# Farscape.enabled_plugins # A list of plugins in the enabled state 
# Farscape.disabled_plugins # A list of plugins in the disables state 
# Farscape.enable(options) # options is a hash, name or type are allowed keys, enables matching plugins 
# Farscape.disable(options) # options is a hash, name or type are allowed keys, enables matching plugins 

# Sample Workflow for Enable/Disable
# Farscape.register_plugin({name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]})
# Farscape.plugins #=> [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]
# Farscape.enabled_plugins #=> [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]
# Farscape.disabled_plugins #=> []
# Farscape.disable(type: :sebacean)
# Farscape.enabled_plugins #=> []
# Farscape.disabled_plugins #=> [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]
# Farscape.disable(name: :Peacekeeper)
# Farscape.enabled_plugins #=> [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]
# Farscape.disabled_plugins #=> [] 

# Sample Workflow for extensions
# class HttpPersistentClient
#   def faraday_adapter
#     :net_http_persistent
#   end
# end
# Farscape.register_plugin(name: :http_persist, type: :http, extends: [:HTTPClient], extentsions: [HttpPersistentClient])

# Agent and RepresentorAgent plugin interface
#
# #plguins, #enabled_plugins, #disabled_plugins -> work as per Farscape 
# Agent.using(name or type) # enables a registered plugin for this instance
# Agent.omitting(name or type) # disables a registered plugin for this instance

# Agent and RepresentorAgent workflow
# Farscape.enabled_plugins #=> [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]
# agent = Farscape.Agent.new.omitting(name: :Peacekeeper)
# agent.plugins # => [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]
# agent.enabled_plugins # => []
# agent.plugins # => [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]
# resource = agent.enter(entry_point).transitions[:listing].invoke
# resource.plugins # => [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]
# resource.enabled_plugins # => []
# resource.plugins # => [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]
# details = resource.using(name: :Peacekeeper).transitions[:items][0].invoke
# details.plugins # => [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]
# details.enabled_plugins # => []
# details.disabled_plugins # => [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]

describe Farscape do

  context 'configuring plugins' do

    after(:each) { Farscape.clear }

    it 'can register a plugin' do
      plugin = {name: :Peacekeeper, type: :sebacean}
      expect(Farscape.register_plugin(plugin)).to be
      expect(Farscape.plugins).to eq([plugin])
    end

    it 'can preemptively disable a plugin by name' do
      Farscape.disable(:Peacekeeper)
      plugin = {name: :Peacekeeper, type: :sebacean}
      expect(Farscape.register_plugin(plugin)).not_to be
      expect(Farscape.plugins).to be_empty
      expect(Farscape).to be_disabled(plugin)
    end

    it 'can preemptively disable a plugin by type' do
      Farscape.disable(:sebacean)
      plugin = {name: :Peacekeeper, type: :sebacean}
      expect(Farscape.register_plugin(plugin)).not_to be
      expect(Farscape.plugins).to be_empty
    end

    it "can disable a plugin after it's added" do
      Farscape.register_plugin(name: :Peacekeeper, type: :sebacean)
      Farscape.register_plugin(name: :Imperium, type: :scarran)
      Farscape.disable(:sebacean)
      expect(Farscape.plugins).to be_one
    end

    it "can reenable a plugin after it's been disabled" do
      Farscape.register_plugin(name: :Peacekeeper, type: :sebacean)
      Farscape.register_plugin(name: :Imperium, type: :scarran)
      Farscape.disable(:sebacean)
      expect(Farscape.plugins).to eq([{:name=>:Imperium, :type=>:scarran}])
      Farscape.reenable(name: :Peacekeeper, type: :sebacean)
      expect(Farscape.plugins).to eq([{:name=>:Imperium, :type=>:scarran}, {:name=>:Peacekeeper, :type=>:sebacean}])
    end

    context 'adding middleware' do

      it 'can add middleware' do
        plugin = {name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}
        Farscape.register_plugin(plugin)
        expect(Farscape.middleware_stack.map{ |elt| elt[:class] } ).to eq([TestMiddleware::NoGetNoProblem])
      end

      it 'removes middleware when the source plugin is disabled' do
        plugin = {name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}
        Farscape.register_plugin(plugin)
        Farscape.disable( :sebacean )
        expect(Farscape.middleware_stack).to be_none
      end

      it 'uses the middleware when making requests' do
        plugin = {name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}
        Farscape.register_plugin(plugin)
        expect{Farscape::Agent.new("http://localhost:#{RAILS_PORT}").enter}.to raise_error('Shazam!')
      end

      it 'can configure middleware' do
        plugin = {name: :Peacekeeper, type: :sebacean, middleware: [{class: TestMiddleware::NoGetNoProblem, config: {permissive: true}}]}
        Farscape.register_plugin(plugin)
        expect{Farscape::Agent.new("http://localhost:#{RAILS_PORT}").enter}.not_to raise_error('Shazam!')
      end


      [:sebacean, TestMiddleware::SabotageDetector,'TestMiddleware::SabotageDetector',['TestMiddleware::SabotageDetector']].each do |form|
        it "honors the before: option in middleware when given as #{form.inspect}" do
          saboteur_middleware = {class: TestMiddleware::Saboteur, before: form}
          saboteur_plugin = {name: :saboteur, type: :scarran, middleware: [saboteur_middleware]}
          detector_plugin = {name: :saboteur, type: :sebacean, middleware: [TestMiddleware::SabotageDetector]}
          [saboteur_plugin, detector_plugin].shuffle.each { |plugin| Farscape.register_plugin(plugin) }
          expect(Farscape.middleware_stack.map{ |m| m[:class] }).to eq( [TestMiddleware::Saboteur, TestMiddleware::SabotageDetector] )
          expect{Farscape::Agent.new("http://localhost:#{RAILS_PORT}").enter}.to raise_error('Sabotage detected')
        end
      end

      [:sebacean, TestMiddleware::SabotageDetector,'TestMiddleware::SabotageDetector',['TestMiddleware::SabotageDetector']].each do |form|
        it "honors the after: option in middleware when given as #{form.inspect}" do
          saboteur_middleware = {class: TestMiddleware::Saboteur, after: form}
          saboteur_plugin = {name: :saboteur, type: :scarran, middleware: [saboteur_middleware]}
          detector_plugin = {name: :saboteur, type: :sebacean, middleware: [TestMiddleware::SabotageDetector]}
          [saboteur_plugin, detector_plugin].shuffle.each { |plugin| Farscape.register_plugin(plugin) }
          expect(Farscape.middleware_stack.map{ |m| m[:class] }).to eq( [TestMiddleware::SabotageDetector, TestMiddleware::Saboteur] )
          expect{Farscape::Agent.new("http://localhost:#{RAILS_PORT}").enter}.not_to raise_error('Sabotage detected')
        end
      end

    end

  end

end
