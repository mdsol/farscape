require 'spec_helper'

module Farscape
  describe AvailableMiddleware do
    it 'starts with empty set of available middlewares' do
      expect(AvailableMiddleware.all).to be_empty
    end
    context 'a class inherith from middleware' do
      before do
        class MyMiddle < AvailableMiddleware
        end
      end

      it 'adds inherited classes as middlewares' do
        expect(AvailableMiddleware.all.size).to eq(1)
        expect(AvailableMiddleware.all.first).to eq(MyMiddle)
      end

      after do
        AvailableMiddleware.clear_middlewares
      end

    end
  end
end