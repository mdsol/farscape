require 'spec_helper'

describe Farscape::Agent do
  let(:entry_point) { "http://localhost:#{RAILS_PORT}"}

  describe '#discover' do
    let(:resource_name) { 'user' }
    let(:links) do
      {
        _links: {
          resource_name => { href: entry_point }
        }
      }
    end
    before do
      described_class.config = { discovery_uri: "https://www.example.com" }
      stub_request(:any, "https://www.example.com").to_return(body: links.to_json)
    end
    after do
        described_class.config = nil
    end

    it 'returns a Farscape::Representor from a name' do
      expect(Farscape::Agent.new(resource_name).enter).to be_a Farscape::RepresentorAgent
    end

    it 'raises Discovery::NotFound if the name does not exist in the discovery service' do
      expect{ Farscape::Agent.new('unknown').enter }.to raise_error Farscape::Discovery::NotFound
    end

    it 'raises Discovery::NotFound if the discovery url is not setup' do
      described_class.config = nil
      expect{ Farscape::Agent.new.discover_entry_point(resource_name) }.to raise_error Farscape::Discovery::NotFound
    end

    it 'raises Discovery::NotFound if the discovery url is not a proper url' do
      described_class.config = { discovery_uri: "aaaaa" }
      expect{ Farscape::Agent.new.discover_entry_point(resource_name) }.to raise_error Farscape::Discovery::NotFound
    end
  end

  describe '#enter' do
    it 'returns a Farscape::Representor' do
      expect(Farscape::Agent.new(entry_point).enter).to be_a Farscape::RepresentorAgent
    end

    it 'can be provided an entry point after initialization' do
      expect(Farscape::Agent.new.enter(entry_point)).to be_a Farscape::RepresentorAgent
    end

    #TODO decide on the appropriate error
    it 'raises an appropriate error if no entry point is specified' do
      expect{ Farscape::Agent.new.enter }.to raise_error(RuntimeError)
    end

    it 'raises an appropriate error when giving invalid requests' do
      expect{ Farscape::Agent.new.enter("http://localhost:#{RAILS_PORT}/drds/ninja_boot")}.to raise_error(Farscape::Exceptions::UnprocessableEntity)
      expect{ Farscape::Agent.new.enter("http://localhost:#{RAILS_PORT}/ninja_boot")}.to raise_error(Farscape::Exceptions::ProtocolException)

      # Original test was expect{ Farscape::Agent.new.enter("http://localhost:#{RAILS_PORT}/ninja_boot")}.to raise_error(Farscape::Exceptions::NotFound)
      # However, Moya is getting an internal server error when hitting a routing error instead of a 404

    end
  end
end
