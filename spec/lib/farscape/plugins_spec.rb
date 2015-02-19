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
