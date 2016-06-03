$LOAD_PATH.unshift 'lib'
require 'farscape/version'

Gem::Specification.new do |s|
  s.name          = 'farscape'
  s.version       = Farscape::VERSION
  s.license       = 'MIT'
  s.date          = Time.now.strftime('%Y-%m-%d')
  s.summary       = 'It shoots through wormholes and takes you to unknown places in the universe!'
  s.homepage      = 'https://github.com/mdsol/farscape'
  s.email         = ''
  s.authors       = ['Mark W. Foster']
  s.files         = ['lib/**/*', 'spec/**/*', 'tasks/**/*', '[A-Z]*'].map { |glob| Dir[glob] }.inject([], &:+)
  s.require_paths = ['lib']
  s.rdoc_options  = ['--main', 'README.md']

  s.description   = <<-DESC
    Farscape is a library that simplifies consuming Hypermedia API responses.
  DESC

  s.add_dependency 'activesupport'
  s.add_dependency 'addressable', '~> 2.3'
  s.add_dependency 'faraday', '~> 0.9'
  s.add_dependency 'rake'
  s.add_dependency 'representors', '~> 0.0.5'

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'redcarpet', '~> 3.3'
  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'webmock', '~> 2.0'
  s.add_development_dependency 'simplecov', '~> 0.11'
  s.add_development_dependency 'yard'
end
