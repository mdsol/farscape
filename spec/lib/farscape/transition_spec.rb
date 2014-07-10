require 'spec_helper'

module Farscape
  describe Transition do
    let(:empty_transition) { ::Representors::Transition.new({})}
    let(:empty_farscape_transition) { Transition.new(empty_transition)}

    describe '.new' do
      it 'returns the correct class' do
        expect(empty_farscape_transition.class).to eq(Farscape::Transition)
      end

      it '#instance_of? Transition is true' do
        expect(empty_farscape_transition).to be_instance_of(Farscape::Transition)
      end

      it '#instance_of? OtherClass is false' do
        expect(empty_farscape_transition).to_not be_instance_of(Farscape::SimpleAgent)
      end

    end
  end
end