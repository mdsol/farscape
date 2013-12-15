require 'spec_helper'

describe Farscape do
  let(:config) { Farscape.config }
  
  after do
    Farscape.send(:reset_config)
  end
  
  describe '.config' do
    it 'memoizes' do
      config.object_id.should == ::Farscape.config.object_id
    end
    
    it 'returns a Configuration::Base instance' do
      config.should be_instance_of(Farscape::Configuration::Base)
    end
  end
  
  describe '.configure' do
    it 'evaluates a block in the context of the module' do
      configuration = nil
      Farscape.configure do
        configuration = config
      end

      configuration.should_not be_nil
    end
  end
end
