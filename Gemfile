source 'https://rubygems.org'
gemspec

gem 'debugger',      '~> 1.6.6'
gem 'yard',          '~> 0.8.5'
gem 'rake',          '~> 0.9'
gem 'awesome_print', '~> 1.1.0'
gem 'redcarpet'

gem 'representors', git: 'https://www.github.com/mdsol/crichton-representors.git', branch: '0-0-stable'

group :development, :test do
  gem 'pry'
  gem 'crichton_test_service', path: '~/Desktop/crichton_test_service'
  gem 'crichton', git: 'git@github.com:mdsol/crichton.git', branch: 'develop'
end

group :test do
  gem 'webmock',        '~> 1.13.0'
  gem 'rspec',          '~> 2.14'
  gem 'simplecov',      '~> 0.7'
end
