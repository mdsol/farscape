require 'spec_helper'

describe Farscape::Agent do
  describe '#instance' do
    it 'returns an Farscape::Agent object' do
      expect(described_class.instance.class).to eq(described_class)
    end

    it 'returns the same agent if called twice' do
      agent1 = described_class.instance
      expect(described_class.instance).to eq(agent1)
    end
  end

  describe '#config' do
    it 'defaults to an empty hash' do
      expect(described_class.config).to eq({})
    end

    it 'can be set' do
      described_class.config = { me: 'too' }
      expect(described_class.config).to eq( me: 'too' )
      described_class.config = nil
    end
  end
end
