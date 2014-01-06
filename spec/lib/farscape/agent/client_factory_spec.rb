require 'spec_helper'
require 'farscape/agent/client_factory'

module Farscape
  class Agent
    describe ClientFactory do
      let(:factory) { Class.new(ClientFactory) }
      
      describe '.build' do
        it 'returns a client class instantiated with options and a block' do
          client_class = double('client_class')
          class_builder = double('class_builder')
          options = double('options')
          client_class.stub(:new).with(options).and_yield(class_builder)
          factory.stub(:registered_classes).and_return({ scheme: client_class })
          
          factory.build(:scheme, options) do |builder|
            builder.should == class_builder
          end
        end
        
        it 'raises an error for unregistered schemes' do
          expect { factory.build(:bogus_scheme) }.to raise_error(UnregisteredClientError)
        end
      end
      
      describe '.register' do
        it 'adds registered client classes' do
          klass = double('client_class')
          factory.register(:scheme, klass)
          factory.registered_classes[:scheme].should == klass
        end
      end
      
      describe '.registered_classes' do
        it 'memoizes' do
          registered_classes = factory.registered_classes
          factory.registered_classes.object_id.should == registered_classes.object_id
        end
        
        it 'is empty when no classes are registered' do
          factory.registered_classes.should be_empty
        end
      end

      describe '.registered_classes?' do
        it 'returns true when there are registered classes' do
          factory.stub(:registered_classes).and_return({ some: double('class') })
          factory.registered_classes?.should be_true
        end

        it 'returns false when there are no registered classes' do
          factory.registered_classes?.should be_false
        end
      end
    end
  end
end
