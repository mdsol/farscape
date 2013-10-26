require 'dice_bag'

module Farscape
  module DiceBag
    class Template < ::DiceBag::AvailableTemplates
      def self.templates_location
        File.join('config', Object.const_defined?('Rails') ? 'initializers' : '')
      end
      
      def templates_location
        self.class.templates_location
      end
    
      def templates
        [File.join(File.dirname(__FILE__), 'farscape.rb.dice')]
      end
    end
  end
end
