require 'spec_helper'
require 'farscape/cache'

describe(Farscape) do

  describe 'cache' do

    after(:each) { Farscape.cache = nil }

    it 'defaults to a memory store' do
      expect(Farscape.cache).to be_a(ActiveSupport::Cache::MemoryStore)
    end

    it 'can be set to any store' do
      custom_cache = Object.new
      Farscape.cache = custom_cache
      expect(Farscape.cache).to eq(custom_cache)
    end

  end

end
