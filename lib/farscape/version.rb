# Used to prevent the class/module from being loaded more than once
unless defined?(::Farscape::VERSION)
  module Farscape
    VERSION = '1.3.0'.freeze
  end
end
