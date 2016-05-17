# Used to prevent the class/module from being loaded more than once
unless defined?(::Farscape::VERSION)
  module Farscape
    VERSION = '1.2.0'.freeze
  end
end
