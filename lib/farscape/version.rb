# Used to prevent the class/module from being loaded more than once
unless defined?(::Farscape::VERSION)
  module Farscape
    VERSION = '1.1.1'.freeze
  end
end
