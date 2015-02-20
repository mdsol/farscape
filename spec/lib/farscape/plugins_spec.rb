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

describe Farscape do
  after(:all) { Farscape.clear }  
  

  context 'configuring plugins' do

    before(:each) { Farscape.clear }
    

    it 'can register a plugin' do
      plugin = {name: :Peacekeeper, type: :sebacean}
      expect(Farscape.register_plugin(plugin)).to be
      expect(Farscape.plugins).to eq({Peacekeeper: plugin})
    end

    it 'can preemptively disable a plugin by name' do
      Farscape.disable!(:Peacekeeper)
      plugin = {name: :Peacekeeper, type: :sebacean}
      Farscape.register_plugin(plugin)
      expect(Farscape.enabled_plugins).to be_empty
      expect(Farscape.disabled?(plugin)).to be_true
      expect(Farscape.enabled?(plugin)).to be_false
    end

    it 'can preemptively disable a plugin by type' do
      Farscape.disable!(:sebacean)
      plugin = {name: :Peacekeeper, type: :sebacean}
      Farscape.register_plugin(plugin)
      expect(Farscape.enabled_plugins).to be_empty
      expect(Farscape.disabled?(plugin)).to be_true
      expect(Farscape.enabled?(plugin)).to be_false
    end

    it "can disable a plugin after it's added" do
      Farscape.register_plugin(name: :Peacekeeper, type: :sebacean)
      Farscape.register_plugin(name: :Imperium, type: :scarran)
      Farscape.disable!(:sebacean)
      expect(Farscape.enabled_plugins).to be_one
    end
    
    context 'adding middleware' do
      
      before(:each) { Farscape.clear }

      it 'can add middleware' do
        plugin = {name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}
        Farscape.register_plugin(plugin)
        
        expect(Farscape.middleware_stack.map{ |elt| elt[:class] } ).to eq([TestMiddleware::NoGetNoProblem])
      end

      it 'removes middleware when the source plugin is disabled' do
        plugin = {name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}
        Farscape.register_plugin(plugin)
        Farscape.disable!( :sebacean )
        
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

      it 'adds middleware to disabled when disabled' do
          plugin = {name: :Peacekeeper, default_state: :disabled, type: :sebacean, middleware: [{class: TestMiddleware::NoGetNoProblem, config: {permissive: true}}]}
          Farscape.register_plugin(plugin)
          
          expect(Farscape.enabled_plugins).to eq({})
          expect(Farscape.disabled_plugins).to eq(plugin[:name] => plugin)
      end

      [:sebacean, TestMiddleware::SabotageDetector,'TestMiddleware::SabotageDetector',['TestMiddleware::SabotageDetector']].each do |form|
        it "honors the before: option in middleware when given as #{form.inspect}" do
          saboteur_middleware = {class: TestMiddleware::Saboteur, before: form}
          saboteur_plugin = {name: :saboteur, type: :scarran, middleware: [saboteur_middleware]}
          detector_plugin = {name: :detector, type: :sebacean, middleware: [TestMiddleware::SabotageDetector]}
          [saboteur_plugin, detector_plugin].shuffle.each { |plugin| Farscape.register_plugin(plugin) }
          
          expect(Farscape.middleware_stack.map{ |m| m[:class] }).to eq( [TestMiddleware::Saboteur, TestMiddleware::SabotageDetector] )
          expect{Farscape::Agent.new("http://localhost:#{RAILS_PORT}").enter}.to raise_error('Sabotage detected')
        end
      end

      [:sebacean, TestMiddleware::SabotageDetector,'TestMiddleware::SabotageDetector',['TestMiddleware::SabotageDetector']].each do |form|
        it "honors the after: option in middleware when given as #{form.inspect}" do
          saboteur_middleware = {class: TestMiddleware::Saboteur, after: form}
          saboteur_plugin = {name: :saboteur, type: :scarran, middleware: [saboteur_middleware]}
          detector_plugin = {name: :detector, type: :sebacean, middleware: [TestMiddleware::SabotageDetector]}
          [saboteur_plugin, detector_plugin].shuffle.each { |plugin| Farscape.register_plugin(plugin) }
          
          expect(Farscape.middleware_stack.map{ |m| m[:class] }).to eq( [TestMiddleware::SabotageDetector, TestMiddleware::Saboteur] )
          expect{Farscape::Agent.new("http://localhost:#{RAILS_PORT}").enter}.not_to raise_error('Sabotage detected')
        end
      end
      
      it 'doesn\'t disable everything with one' do
        detector_plugin = {name: :detector, type: :sebacean, middleware: [TestMiddleware::SabotageDetector], default_state: :disabled}
        saboteur_middleware = {class: TestMiddleware::Saboteur}
        saboteur_plugin = {name: :saboteur, type: :scarran, middleware: [saboteur_middleware]}
        Farscape.register_plugin(detector_plugin)
        Farscape.register_plugin(saboteur_plugin)
        
        expect(Farscape.enabled_plugins.keys).to eq([:saboteur])
      end

    end

    context 'workflow' do
      
      before(:each) { Farscape.clear }
      
      it 'manages enabling and disabling plugins' do
        registration = [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]
        registration_keys = registration.map { |plugin| plugin[:name] }
        Farscape.register_plugins(registration)
        
        expect(Farscape.plugins.keys).to eq( registration_keys )
        expect(Farscape.enabled_plugins.keys).to eq( registration_keys )
        expect(Farscape.disabled_plugins.keys).to eq([])
        
        Farscape.disable!(type: :sebacean)
        
        expect(Farscape.enabled_plugins.keys).to eq([])
        expect(Farscape.disabled_plugins.keys).to eq( registration_keys )
        
        Farscape.enable!(name: :Peacekeeper)
        
        expect(Farscape.enabled_plugins.keys).to eq( registration_keys )
        expect(Farscape.disabled_plugins.keys).to eq([])
      end
      
    end

  end

end
