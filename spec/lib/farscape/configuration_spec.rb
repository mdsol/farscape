require 'spec_helper'

module Farscape
  describe Configuration do
    let(:config) { Farscape::Configuration.config }
  
    after do
      Farscape.send(:reset_config)
    end
  
    describe '.config' do
      it 'memoizes' do
        config.object_id.should == ::Farscape::Configuration.config.object_id
      end
  
      it 'returns a Configuration::Base instance' do
        config.should be_instance_of(Farscape::Configuration::Base)
      end
    end
  
    describe '.configure' do
      it 'evaluates a block in the context of the module' do
        configuration = nil
        Farscape::Configuration.configure do
          configuration = config
        end
  
        configuration.should_not be_nil
      end
    end
  end
end
