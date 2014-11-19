require 'spec_helper'

describe Farscape::Agent do
  let(:entry_point) { "http://localhost:1234"}

  describe '#enter' do
    it 'returns a Farscape::Representor' do
      expect(Farscape::Agent.new(entry_point).enter).to be_a Farscape::Representor
    end
  end
end