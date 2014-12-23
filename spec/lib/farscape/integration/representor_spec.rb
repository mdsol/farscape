require 'spec_helper'

describe Farscape::Representor do
  let(:entry_point) { "http://localhost:#{RAILS_PORT}"}

  describe '#transitions' do
    it 'returns a hash of tranistions' do
      representor = Farscape::Agent.new(entry_point).enter
      expect(representor.transitions["drds"].uri).to eq("http://localhost:1234/drds")
    end

    it 'responds to keys appropriately' do
      representor = Farscape::Agent.new(entry_point).enter
      expect(representor.transitions["drds"].invoke.transitions.keys).to eq(["self", "search", "items", "profile", "type", "help"])
    end
   end

   describe "#invoke" do
      it 'returns a representor' do
        representor = Farscape::Agent.new(entry_point).enter
         expect(representor.transitions["drds"].invoke).to be_a Farscape::Representor
      end

      it 'can reload a resource' do
        representor = Farscape::Agent.new(entry_point).enter.transitions["drds"].invoke
        expect(representor.transitions["self"].invoke.to_hash).to eq(representor.to_hash)
      end
   end

  describe '#attributes' do
    it 'has readable attributes' do
      representor = Farscape::Agent.new(entry_point).enter
      expect(representor.transitions["drds"].invoke.attributes["total_count"]).to be > 4
    end
  end
end
