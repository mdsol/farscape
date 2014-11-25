require 'spec_helper'

describe Farscape::Agent do
  let(:entry_point) { "http://localhost:#{RAILS_PORT}"}

  describe '#enter' do
    it 'returns a Farscape::Representor' do
      expect(Farscape::Agent.new(entry_point).enter).to be_a Farscape::Representor
    end

    it 'can be provided an entry point after initialization' do
      expect(Farscape::Agent.new.enter(entry_point)).to be_a Farscape::Representor
    end

    #TODO decide on the appropriate error
    it 'raises an appropriate error if no entry point is specified' do
      expect{ Farscape::Agent.new.enter }.to raise_error(RuntimeError)
    end
  end
end
