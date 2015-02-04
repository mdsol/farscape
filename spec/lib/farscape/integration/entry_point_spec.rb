require 'spec_helper'

describe Farscape::Agent do
  let(:entry_point) { "http://localhost:#{RAILS_PORT}"}

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
