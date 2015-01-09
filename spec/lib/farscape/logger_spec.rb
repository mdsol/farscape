require 'spec_helper'
require 'farscape/logger'

describe(Farscape) do

  describe 'logger' do

    after(:each) { Farscape.logger = nil }

    it 'defaults to the built-in Ruby logger' do
      Farscape.logger = nil
      expect(Farscape.logger).to be_a(::Logger)
    end

    it 'can be set to any kind of logger' do
      custom_logger = Object.new
      Farscape.logger = custom_logger
      expect(Farscape.logger).to eq(custom_logger)
    end

  end

end
