require 'spec_helper'

module Farscape
  describe Configuration do
    let(:config) { Farscape.config }
    let(:template_path) { File.join(Farscape::DiceBag::Template.templates_location, 'farscape.rb') }

    before do
      stub_dice_bag_templates
      config.send(:reset)
      load "#{template_path}"
    end
    
    describe '#config' do
      it 'memoizes' do
        config.object_id.should == ::Farscape.config.object_id
      end
    end
  end
end
