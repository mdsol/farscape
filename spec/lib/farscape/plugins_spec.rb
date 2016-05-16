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

describe Farscape::Agent do

  before(:each) do
    Farscape.clear
    detector_plugin = {name: :Detector, type: :sebacean, middleware: [TestMiddleware::SabotageDetector], default_state: :disabled}
    saboteur_middleware = {class: TestMiddleware::Saboteur, before: :sebacean}
    saboteur_plugin = {name: :Saboteur, type: :scarran, middleware: [saboteur_middleware]}
    Farscape.register_plugin(detector_plugin)
    Farscape.register_plugin(saboteur_plugin)
  end

  after(:all) { Farscape.clear }

  let(:entry_point) { "http://localhost:#{RAILS_PORT}"}
  let(:can_do_hash) { {conditions: 'can_do_anything'} }

  it 'accepts a using directive that enables a plugin' do
    expect { Farscape::Agent.new(entry_point).using(:Detector).enter }.to raise_error('Sabotage detected')
  end

  it 'accepts an omitting directive that disables a plugin' do
    agent = Farscape::Agent.new(entry_point).using(:Detector)
    agent = agent.omitting(:sebacean)
    expect { agent.enter }.to_not raise_error
  end

  it 'allows showing the list of registered plugins' do
    expect(Farscape::Agent.new(entry_point).plugins).to eq(Farscape.plugins)
  end

  it 'allows showing only those enabled for the agent' do
    agent = Farscape::Agent.new(entry_point).using(:Detector)
    expect(agent.enabled_plugins[:Detector]).to_not be_nil
    expect(Farscape.disabled_plugins[:Detector]).to_not be_nil
  end

  it 'allows showing only those disabled for the agent' do
    agent = Farscape::Agent.new(entry_point).using(:Detector)
    agent = agent.omitting(:sebacean)
    expect(agent.disabled_plugins.keys).to eq([:Detector])
    expect(Farscape.enabled_plugins.keys).to eq([:Saboteur])
  end

  it 'allows using on TransitionAgent objects' do
    transition = Farscape::Agent.new(entry_point).enter.transitions["drds"].using(:Detector)
    expect { transition.invoke { |req| req.parameters = can_do_hash } }.to raise_error('Sabotage detected')
    expect(transition.disabled_plugins).to eq({})
  end

  it 'allows using on RepresentorAgent objects' do
    representor = Farscape::Agent.new(entry_point).enter.using(:Detector)
    transition = representor.transitions["drds"]
    expect { transition.invoke { |req| req.parameters = can_do_hash } }.to raise_error('Sabotage detected')
    expect(representor.disabled_plugins).to eq({})
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
      expect(Farscape.disabled?(plugin)).to be true
      expect(Farscape.enabled?(plugin)).to be false
    end

    it 'can preemptively disable a plugin by type' do
      Farscape.disable!(:sebacean)
      plugin = {name: :Peacekeeper, type: :sebacean}
      Farscape.register_plugin(plugin)
      expect(Farscape.enabled_plugins).to be_empty
      expect(Farscape.disabled?(plugin)).to be true
      expect(Farscape.enabled?(plugin)).to be false
    end

    it "can disable a plugin after it's added" do
      Farscape.register_plugin(name: :Peacekeeper, type: :sebacean)
      Farscape.register_plugin(name: :Imperium, type: :scarran)
      Farscape.disable!(:sebacean)
      expect(Farscape.enabled_plugins).to be_one
    end

    context 'adding middleware' do

      before(:each) { Farscape.clear }
      after(:all) { Farscape.clear }

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

        expect{Farscape::Agent.new("http://localhost:#{RAILS_PORT}").enter}.not_to raise_error
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
          saboteur_plugin = {name: :Saboteur, type: :scarran, middleware: [saboteur_middleware]}
          detector_plugin = {name: :Detector, type: :sebacean, middleware: [TestMiddleware::SabotageDetector]}
          [saboteur_plugin, detector_plugin].shuffle.each { |plugin| Farscape.register_plugin(plugin) }

          expect(Farscape.middleware_stack.map{ |m| m[:class] }).to eq( [TestMiddleware::Saboteur, TestMiddleware::SabotageDetector] )
          expect{Farscape::Agent.new("http://localhost:#{RAILS_PORT}").enter}.to raise_error('Sabotage detected')
        end
      end

      [:sebacean, TestMiddleware::SabotageDetector,'TestMiddleware::SabotageDetector',['TestMiddleware::SabotageDetector']].each do |form|
        it "honors the after: option in middleware when given as #{form.inspect}" do
          saboteur_middleware = {class: TestMiddleware::Saboteur, after: form}
          saboteur_plugin = {name: :Saboteur, type: :scarran, middleware: [saboteur_middleware]}
          detector_plugin = {name: :Detector, type: :sebacean, middleware: [TestMiddleware::SabotageDetector]}
          [saboteur_plugin, detector_plugin].shuffle.each { |plugin| Farscape.register_plugin(plugin) }

          expect(Farscape.middleware_stack.map{ |m| m[:class] }).to eq( [TestMiddleware::SabotageDetector, TestMiddleware::Saboteur] )
          expect{Farscape::Agent.new("http://localhost:#{RAILS_PORT}").enter}.not_to raise_error
        end
      end

      it 'doesn\'t disable everything with one' do
        detector_plugin = {name: :Detector, type: :sebacean, middleware: [TestMiddleware::SabotageDetector], default_state: :disabled}
        saboteur_middleware = {class: TestMiddleware::Saboteur}
        saboteur_plugin = {name: :Saboteur, type: :scarran, middleware: [saboteur_middleware]}
        Farscape.register_plugin(detector_plugin)
        Farscape.register_plugin(saboteur_plugin)

        expect(Farscape.enabled_plugins.keys).to eq([:Saboteur])
      end

      it 'doesn\'t allow sneaky enabling' do
        detector_plugin = {name: :Detector, type: :sebacean, middleware: [TestMiddleware::SabotageDetector], default_state: :disabled}
        Farscape.register_plugin(detector_plugin)

        expect(Farscape.disabled_plugins.keys).to eq([:Detector])

        detector_plugin = {name: :Detector, type: :sebacean, middleware: [TestMiddleware::SabotageDetector], default_state: :enabled}
        Farscape.register_plugin(detector_plugin)

        expect(Farscape.disabled_plugins.keys).to eq([:Detector])
      end

    end

    context 'extensions' do
      before(:each) { Farscape.clear }
      after(:all) { Farscape.clear }

      let(:entry_point) { "http://localhost:#{RAILS_PORT}"}
      let(:can_do_hash) { {conditions: 'can_do_anything'} }

      it 'allows extensions' do
        module Peacekeeper
          def pacify!
            raise 'none shall pass' unless enabled_plugins.include?(:Saboteur)
          end
        end
        Farscape.register_plugin(name: :Peacekeeper, type: :security, extensions: {Agent: [Peacekeeper]})
        expect { Farscape::Agent.new.pacify! }.to raise_error('none shall pass')
      end

      it 'allows extensions with altering existing methods' do
        module Peacemaker
          def self.extended(base)
            base.instance_eval do
              @original_transitions = method(:transitions)
              def transitions
                raise 'none shall pass' if @original_transitions.call.keys.include?("drds")
                @original_transitions.call
              end
            end
          end
        end
        Farscape.register_plugin(name: :Peacekeeper, type: :security, extensions: {RepresentorAgent: [Peacemaker]})
        expect { Farscape::Agent.new.enter(entry_point).transitions.keys }.to raise_error('none shall pass')
        expect(Farscape::Agent.new.enter(entry_point).omitting(:Peacekeeper).transitions.keys).to include("drds")
      end

      it 'allows discovery extensions' do
        module ServiceCatalogue
          def self.extended(base)
            base.instance_eval do
              @original_enter = method(:enter)
              @dispatches = {
                :moya => "http://localhost:#{RAILS_PORT}"
              }
              def enter(entry=nil)
                @entry_point ||= entry
                @entry_point = @dispatches[@entry_point] || @entry_point
                @original_enter.call
              end
            end
          end
        end
        Farscape.register_plugin(name: :Wormlet, type: :discovery, extensions: {Agent: [ServiceCatalogue]})
        expect(Farscape::Agent.new(:moya).enter.transitions.keys).to include("drds")
        expect(Farscape::Agent.new.enter(:moya).transitions.keys).to include("drds")
        expect { Farscape::Agent.new.omitting(:discovery).enter(:moya).transitions.keys }.to raise_error(NoMethodError)
      end

    end

    context 'workflow' do

      before(:each) { Farscape.clear }

      let(:entry_point) { "http://localhost:#{RAILS_PORT}"}
      let(:can_do_hash) { {conditions: 'can_do_anything'} }

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

      it 'managed complex enabling and disabling on instances' do
        registration = [{name: :Peacekeeper, type: :sebacean, middleware: [TestMiddleware::NoGetNoProblem]}]
        registration_keys = registration.map { |plugin| plugin[:name] }
        Farscape.register_plugins(registration)
        peacekeeper_plugin = {:Peacekeeper=>{:name=>:Peacekeeper, :type=>:sebacean, :middleware=>[TestMiddleware::NoGetNoProblem], :enabled=>true}}
        disabled_plugin = {:Peacekeeper=>{:name=>:Peacekeeper, :type=>:sebacean, :middleware=>[TestMiddleware::NoGetNoProblem], :enabled=>false}}

        expect(Farscape.enabled_plugins).to eq(peacekeeper_plugin)

        agent = Farscape::Agent.new.omitting(name: :Peacekeeper)

        expect(agent.plugins).to eq(disabled_plugin)
        expect(agent.enabled_plugins).to eq({})
        expect(agent.disabled_plugins).to eq(disabled_plugin)

        resource = agent.enter(entry_point).transitions["drds"].invoke { |builder| builder.parameters = can_do_hash }
        expect(resource.plugins).to eq(disabled_plugin)
        expect(resource.enabled_plugins).to eq({})
        expect(resource.plugins).to eq(disabled_plugin)

        transition = resource.using(name: :Peacekeeper).transitions["items"]
        details = resource.using(name: :Peacekeeper).embedded["items"].first

        expect { transition.invoke }.to raise_error('Shazam!')
        expect(details.plugins).to eq(peacekeeper_plugin)
        expect(details.enabled_plugins).to eq(peacekeeper_plugin)
        expect(details.disabled_plugins).to eq({})
      end

    end

  end

end
