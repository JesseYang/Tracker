require 'rbconfig'
HOST_OS = RbConfig::CONFIG['host_os']
source 'https://rubygems.org'
#source 'http://ruby.taobao.org'

gem 'rails', '3.2.9'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'


gem 'devise', '~> 3.0.0'
gem 'mongoid', '~> 3.1.4'
gem 'haml', '~> 4.0.0'
gem 'sidekiq', '~> 2.8.0'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'slim'
gem 'kaminari', '~> 0.14.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem "less-rails", '~> 2.4.2'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'twitter-bootstrap-rails', '~> 2.2.8'
end

gem 'libv8', '~> 3.16.14.3'
gem 'jquery-rails', '~> 3.0.4'
gem 'nokogiri'
gem 'httparty', '~> 0.10.2'
gem 'whenever', '~> 0.8.2', :require => false

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

group :development do
  gem 'pry-rails', "~> 0.2.2"
  gem "better_errors", "~> 0.8.0"
  gem "binding_of_caller", "~> 0.7.2"
end
