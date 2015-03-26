require 'spec_helper'
require 'json'
require 'active_support/core_ext/string/filters'

describe Farscape::RepresentorAgent do
  let(:entry_point) { "http://localhost:#{RAILS_PORT}"}

  let(:drds_link) { Farscape::Agent.new(entry_point).enter.transitions["drds"] }
  let(:can_do_hash) { {conditions: 'can_do_anything'} }
  let(:name) { 'Brave New DRD' }
  let(:attrs) { {name: name, status: 'activated', old_status: 'activated'} }

  context 'can do anything' do

    it 'includes appropriate transitions' do
      drds_resource = drds_link.invoke { |req| req.parameters = can_do_hash }
      expect(drds_resource.transitions.keys).to include('create')
    end

    it 'can create a drd' do
      name = 'Brave New DRD'
      drds_resource = drds_link.invoke { |req| req.parameters = can_do_hash }
      drd = drds_resource.transitions['create'].invoke do |req|
        req.attributes = attrs
        req.parameters = can_do_hash
      end
      expect(drd.transitions['self'].invoke.attributes['name']).to eq(name)
      drd.transitions['delete'].invoke # Cleanup, failure here should imply failure in 'can delete a drd'
    end

    context 'an existing drd' do
      before do
        drds_resource = drds_link.invoke { |req| req.parameters = can_do_hash }
        @drd = drds_resource.transitions['create'].invoke do |req|
          req.attributes = attrs
          req.parameters = can_do_hash
        end
      end


      it 'can delete a drd' do
        # NB We compare attributes as the self link will differ between the two calls
        recall_drds = ->() { @drd.transitions['self'].invoke { |r| r.parameters = can_do_hash }.to_hash[:attributes] }
        drd_attributes = @drd.to_hash[:attributes]
        self_attributes = recall_drds.call
        expect(self_attributes).to eq(drd_attributes)
        @drd.transitions['delete'].invoke
        expect { recall_drds.call }.to raise_error( Farscape::Exceptions::NotFound )
      end

      it 'returns proper errors' do
        # NB We compare attributes as the self link will differ between the two calls
        recall_drds = ->() { @drd.transitions['self'].invoke { |r| r.parameters = can_do_hash }.to_hash[:attributes] }
        drd_attributes = @drd.to_hash[:attributes]
        @drd.transitions['delete'].invoke
        begin
          recall_drds.call
          raise Exception.new('Moya responded with a resource that\'s been deleted')
        rescue Farscape::Exceptions::NotFound => e
          expect(e.error_description).to eq('The server has not found anything matching the Request-URI.
          No indication is given of whether the condition is temporary or permanent.
          This status code is commonly used when the server does not wish to reveal exactly why the request has been refused, or when no other response is applicable.'.squish)
          expect(e.representor.to_hash).to eq(e.message)
        end
      end

      it 'can update a drd' do
        new_kind = "sentinel"
        begin
          @drd.transitions['update'].invoke do |r|
            r.attributes = {kind: new_kind}
            r.parameters = can_do_hash
          end
        rescue
          #TODO: Farscape handles redirects
        end
        kindof = @drd.transitions['self'].invoke.attributes['kind']
        expect(kindof).to eq(new_kind)
      end

      it 'can toggle a drds activation state' do
        status = @drd.attributes['status']
        action = status == 'activated' ? 'deactivate' : 'activate'
        @drd.transitions[action].invoke { |r| r.parameters = can_do_hash }
        new_status = @drd.transitions['self'].invoke { |r| r.parameters = can_do_hash }.attributes['status']
        expect(status).to_not eq(new_status)
      end

    end
  end

end
