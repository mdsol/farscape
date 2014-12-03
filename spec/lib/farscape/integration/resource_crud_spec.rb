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
        # NB We compare attributes as the self link will differ between the two calls
        drd_attributes = @drd.to_hash[:attributes]
        self_attributes = @drd.transitions['self'].invoke { |r| r.parameters = can_do_hash }.to_hash[:attributes]
        expect(self_attributes).to eq(drd_attributes)
        @drd.transitions['delete'].invoke
        error_attributes = @drd.transitions['self'].invoke { |r| r.parameters = can_do_hash }.to_hash[:attributes]
        expect(error_attributes).to_not eq(self_attributes)
      end
      
      xit 'can update a drd' do
      end
      
      xit 'can toggle a drds activation state' do
      end 
      
    end
  end

end
