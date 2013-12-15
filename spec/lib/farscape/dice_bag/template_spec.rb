require 'spec_helper'

module Farscape
  module DiceBag
    describe Template do
      let(:subject) { Template.new }
      
      describe '#templates' do
        it 'returns an array that includes the location of template' do
          subject.templates.first.should include('lib/farscape/dice_bag/farscape.rb.dice')
        end
      end
      
      describe '#templates_location' do
        it 'returns a config location' do
          subject.templates_location.should == 'config/'
        end
        
        context 'with Rails defined' do
          it 'returns an initializer location' do
            Object.stub(:const_defined?).with('Rails').and_return(true)
            subject.templates_location.should == 'config/initializers'
          end
        end
      end
    end
  end
end
