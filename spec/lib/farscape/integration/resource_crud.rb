require 'spec_helper'
require 'json'

describe Farscape::Representor do
  let(:entry_point) { "http://localhost:#{RAILS_PORT}"}

  let(:drds_link) { Farscape::Agent.new(entry_point).enter.transitions["drds"] }
  let(:can_do_hash) { {conditions: 'can_do_anything'} }

  context 'can do anything' do
    it 'includes appropriate transitions' do
      drds_resource = drds_link.invoke { |req| req.parameters = can_do_hash }
      expect(drds_resource.transitions.keys).to include('create')
    end

    it 'can create a drd' do
      name = 'Angry Max'
      drds_resource = drds_link.invoke { |req| req.parameters = can_do_hash }
      drd = drds_resource.transitions['create'].invoke { |req| req.parameters = {name: name} }
      expect(drd.transitions['self'].invoke.attributes['name']).to eq(name)
    end

    context 'an existing drd' do
      before do
        drds_resource = drds_link.invoke { |req| req.parameters = can_do_hash }
        @drd = drds_resource.transitions['create'].invoke { |req| req.parameters = params }
      end

      let(:name) { 'Brave New DRD' }
      let(:params) { {name: name}.merge(can_do_hash) }

      it 'can delete a drd' do
        #TODO fix this, expects self to include query string, otherwise identical
        #expect(@drd.transitions['self'].invoke { |r| r.parameters = can_do_hash }.to_hash).to eq(@drd.to_hash)
        @drd.transitions['destroy'].invoke
        expect(@drd.transitions['self'].invoke { |r| r.parameters = can_do_hash }.to_hash).to_not eq(@drd.to_hash)
      end
    end
  end

  # start at the entry entry_point
  # get the drds (list) resource
  # create a resource
  # get that resource
  # determine transitions from that resource (can_do_anything)
  # it can toggle activation
  # it can update
  # it can delete

end
