$LOAD_PATH.unshift 'lib'
require 'farscape/version'

Gem::Specification.new do |s|
  s.name          = 'farscape'
  s.version       = Farscape::VERSION::STRING
  s.date          = Time.now.strftime('%Y-%m-%d')
  s.summary       = 'It shoots through wormholes and takes you to unknown places in the universe!'
  s.homepage      = 'https://github.com//farscape'
  s.email         = ''
  s.authors       = ['Mark W. Foster']
  s.files         = ['lib/**/*', 'spec/**/*', 'tasks/**/*', '[A-Z]*'].map { |glob| Dir[glob] }.inject([], &:+)
  s.require_paths = ['lib']
  s.rdoc_options  = ['--main', 'README.md']

  s.description   = <<-DESC
    Farscape is a library that simplifies consuming Hypermedia API responses.
  DESC

  s.add_dependency 'dice_bag'
  s.add_dependency 'rake'
  s.add_dependency('addressable',   '~> 2.3.0')
  s.add_dependency('faraday',       '~> 0.8.8')
  s.add_development_dependency 'rspec'

end
