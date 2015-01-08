require 'active_support/cache'

module Farscape

  def self.cache
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end

  def self.cache=(new_cache)
    @cache = new_cache
  end

end
