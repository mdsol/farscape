require 'spec_helper'

describe Farscape::Representor do
  let(:entry_point) { "http://localhost:#{RAILS_PORT}"}
  
  let(:drds_link) { Farscape::Agent.new(entry_point).enter.transitions["drds"] }
  
  describe 'can do anything' do
    it 'returns the entry point' do
      drds_resource = drds_link.invoke do |args| 
        args.parameters = {conditions: 'can_do_anything'}
        args
      end
      expect(drds_resource.transitions.keys).to include('create')
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