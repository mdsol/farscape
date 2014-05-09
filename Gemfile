source 'https://rubygems.org'
gemspec

gem 'debugger',      '~> 1.5.0'
gem 'yard',          '~> 0.8.5'
gem 'rake',          '~> 0.9'
gem 'awesome_print', '~> 1.1.0'
gem 'redcarpet'
gem 'faraday-zeromq', :git => 'git@github.com:technoweenie/faraday-zeromq.git'
#gem 'crichton-representors', git: 'git@github.com:mdsol/crichton-representors.git', branch: 'feature/deserializers'
gem 'crichton-representors', path: '../crichton-representors'

group :development, :test do
  gem 'pry'
end

group :test do
  gem 'webmock',        '~> 1.13.0'
  gem 'rspec',          '~> 2.13.0'
  gem 'simplecov',      '~> 0.7.1'     
end
