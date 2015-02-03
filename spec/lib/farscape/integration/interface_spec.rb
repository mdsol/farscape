require 'spec_helper'
require 'json'

describe Farscape::SafeRepresentorAgent do

  # TODO: Make Representor::Field behave like a string

  let(:entry_point) { "http://localhost:#{RAILS_PORT}"}

  let(:drds_link) { Farscape::Agent.new(entry_point).enter.transitions["drds"] }
  let(:can_do_hash) { {conditions: 'can_do_anything'} }

  describe "A Hypermedia API" do
    it 'returns a Farscape::Representor instance
    with a simple state-machine interface of attributes (data)
    and transitions (link/form affordances) for interacting with the resource representations.' do
      agent = Farscape::Agent.new(entry_point)
      resources = agent.enter

      expect(resources.attributes).to eq({})  # TODO: Make Crichton more flexible with Entry Points
      expect(resources.transitions.keys).to eq(["drds"]) # => TODO: Add leviathans to Moya
    end
  end

  describe "A Hypermedia Discovery Service" do
    # TODO: Fix Documentation to reflect this

    it 'follow your nose entry to select a registered resource' do
      agent = Farscape::Agent.new(entry_point)
      resources = agent.enter

      expect(resources.transitions['drds'].invoke).to be_a Farscape::RepresentorAgent
    end

    it 'immediately loading a discoverable resource if known to be registered in the service a priori.' do
      agent = Farscape::Agent.new
      resources = agent.enter(entry_point)

      expect(resources.transitions['drds'].invoke).to be_a Farscape::RepresentorAgent
    end

    it 'throws an error on an unknown resource' do
      agent = Farscape::Agent.new

      expect{ agent.enter }.to raise_error(RuntimeError) # TODO: Create Exact Error Interface for Farscape
    end

  end

  context "API Interaction" do

    let(:agent) { Farscape::Agent.new(entry_point) }
    let(:drds) { agent.enter.transitions['drds'].invoke { |req| req.parameters = can_do_hash } }

    describe "Load a Resource" do
      it 'can load a resource' do
        resources = agent.enter
        drds_transition = resources.transitions['drds']
        drds_resource = drds_transition.invoke { |req| req.parameters = can_do_hash }

        expect(drds_resource.transitions['self'].uri).to eq(drds.transitions['self'].uri)
      end
    end

    describe "A Representor Agent" do
      it "Allows retrieving Response Header Information" do
        resources = agent.enter
        drds = resources.drds
        expect(drds.response.status).to eq(200)
      end
    end

    describe "Reload A Resource" do
      it "can reload a resource" do
        self_transition = drds.transitions['self']
        reloaded_drds = self_transition.invoke

        expect(reloaded_drds.to_hash).to eq(drds.to_hash)
      end
    end

    describe "When using classmethods to refence API elements" do
      context "When following unsafe transitions" do
        it "can follow safe transitions" do
          agent = Farscape::Agent.new
          resources = agent.enter(entry_point)
          expect(resources.drds).to be_a Farscape::RepresentorAgent
        end
        it "requires an ! on unsafe transitions" do
          agent = Farscape::Agent.new
          resources = agent.enter(entry_point)
          expect { resources.drds { |req| req.parameters = can_do_hash }.create }.to raise_error(NoMethodError) # TODO: Create Exact Error Interface for Farscape

          drones = resources.drds { |req| req.parameters = can_do_hash }
          expect(drones.create!.transitions.keys).to include('help')
        end

        it "can be called with arguments" do
          agent = Farscape::Agent.new
          resources = agent.enter(entry_point)
          expect(resources.drds.search(status: 'active').items.all? { |h| h.status }).to be true
        end

        it "can take a block" do
          agent = Farscape::Agent.new
          resources = agent.enter(entry_point)
          resources.drds { |req| req.parameters = can_do_hash }
          resources.drds.search { |req| req.parameters = can_do_hash }

          expect(resources.drds.search(status: 'activated') { |req| req.parameters = can_do_hash }.transitions.keys).to include('create')
          expect(resources.drds.search(status: 'activated') { |req| req.parameters = can_do_hash }.items.all? { |h| h.status == 'activated' }).to be true
        end
      end
      context "When Referencing Attributes" do
        it "can reference attributes" do
          resource = agent.enter(entry_point).drds(can_do_hash).items.first
          expect(resource.status).to eq(drds.embedded['items'].first.attributes['status'])
        end
        it "is read only" do
          resource = agent.enter(entry_point).drds(can_do_hash).items.first
          expect {resource.status = 'ninja food'}.to raise_error(NoMethodError)
        end
        it "throws on unknown" do
          resource = agent.enter(entry_point).drds(can_do_hash).items.select { |drd| drd.status == 'deactivated' }.first
          expect {resource.ninja}.to raise_error(NoMethodError)
          expect {resource.self {|r| r.parameters = {'conditions' => 'can_do_anything'}}.activate!.activate!}.to raise_error(NoMethodError, /undefined method `activate!' for.*/)
        end
      end
      context "When handling namespace collisions" do
        it "can be converted to a safe representor and back" do
          resource = agent.safe.enter.transitions['drds'].invoke { |req| req.parameters = can_do_hash }.embedded['items'].first
          expect {resource.status}.to raise_error(NoMethodError)

          resource = resource.unsafe
          expect(resource.status).to eq(drds.embedded['items'].first.attributes['status'])

          resource = resource.safe
          expect {resource.status}.to raise_error(NoMethodError)
        end
      end

      context "When using Alternate Interface" do
        it "can change to and from a safe representor" do
           drds = agent.enter(entry_point).drds(can_do_hash)
           safely = drds.safe
           unsafely = safely.unsafe
           expect(safely.attributes.keys).to eq(unsafely.attributes.keys) # TODO: Representor should support descriptor equality
           expect(safely.transitions.keys).to eq(unsafely.transitions.keys) # TODO: Representor should support descriptor equality
           expect(safely.embedded.keys).to eq(unsafely.embedded.keys) # TODO: Representor should support descriptor equality
        end
      end

    end

    context "Explore" do
      describe "Apply Query Parameters" do
        it 'allows Application of Query Parameters' do
          search_transition = drds.transitions['search']

          # TODO: Diverges from Doc due to doc not considering Field objects
          expect(search_transition.parameters.map { |p| p.name } ).to eq(['status'])

          filtered_drds = search_transition.invoke do |builder|
            builder.parameters = { status: 'activated' }
          end

          expect(filtered_drds.transitions['items']).to_not be(nil)
        end
      end

      describe "Transform Resource State" do
        it 'allows Transformation of Resource State' do
          embedded_drd_items = drds.embedded # TODO: Orig "drds.items" Looks like New Interface
          drd = embedded_drd_items['items'].first

          expect(drd.attributes.keys).to eq(["id", "name", "status", "old_status", "kind", "size", "leviathan_uuid", "created_at", "location", "location_detail", "destroyed_status"])
          expect(drd.transitions.keys).to include("self", "update", "delete", "leviathan", "profile", "type", "help")

          status = drd.attributes['status']
          action = status == 'activated' ? 'deactivate' : 'activate'
          deactivate_transition = drd.transitions[action]

          # TODO: Not sure what to do about empty response bodies
          # deactivated_drd = deactivate_transition.invoke
          deactivate_transition.invoke { |req| req.parameters = can_do_hash }
          deactivated_drd = drd.transitions['self'].invoke { |req| req.parameters = can_do_hash }

          expect(deactivated_drd.attributes['status']).to_not eq(status)
          expect(deactivated_drd.attributes.keys).to eq(drd.attributes.keys)
          expect(deactivated_drd.transitions.keys).to_not eq(drd.transitions.keys)
        end
      end

      describe "Transform Application State" do
        xit 'allows Transformation of Application State' do
# TODO: Make Moya serve Leviathan as a separate service
#           leviathan_transition = deactivated_drd.transitions['leviathan']
#
#           leviathan = leviathan_transition.invoke
#           leviathan.attributes # => { name: 'Elack' }
#           leviathan.transitions # => ['self', 'drds']
#
#           # Use Attributes
#           create_transition = drds.transitions['create']
#           create_transition.attributes # => ['name']
#
#           new_drd = create_transition.invoke do |builder|
#             builder.attributes = { name: 'Pike' }
#           end
#
#           new_drd.attributes # => { name: 'Pike' }
#           new_drd.transitions # => ['self', 'edit', 'delete', 'deactivate', 'leviathan']
        end
      end
    end
  end
end
