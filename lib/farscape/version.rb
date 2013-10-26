# Used to prevent the class/module from being loaded more than once
unless defined?(::Farscape::VERSION)
  module Farscape
    module VERSION
      MAJOR = 0
      MINOR = 0
      TINY  = 1
    
      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
