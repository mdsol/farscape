source 'https://rubygems.org'
gemspec

gem 'byebug', '~> 3.5.1' if RUBY_VERSION > '2'
gem 'yard',          '~> 0.8.5'
gem 'rake',          '~> 0.9'
gem 'awesome_print', '~> 1.1.0'
gem 'redcarpet'

gem 'representors', git: 'https://www.github.com/mdsol-share/representors.git', branch: '0-0-stable'

group :development, :test do
  gem 'pry'
  #TODO replace both crichton and crichton_test_service with references to stable branches when ready.
  gem 'moya', git: 'https://www.github.com/mdsol/moya.git', branch: 'develop'
  gem 'crichton', git: 'https://www.github.com/mdsol-share/crichton.git', branch: 'develop'
end

group :test do
  gem 'webmock',        '~> 1.13.0'
  gem 'rspec',          '~> 2.14'
  gem 'simplecov',      '~> 0.7'
end
