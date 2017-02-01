# bundle Gemfile
source 'https://rubygems.org'
ruby '2.3.0'

# Default
group :default do
  # Sinatra
  gem 'sinatra', '1.4.7', require: 'sinatra/base'
  gem 'rake', '11.2.2'

  # Database
  gem 'sequel', '~>4.33.0'
  gem 'sinatra-sequel', '0.9.0'

  # Tools
  gem 'will_paginate', '~> 3.1.0'
  gem 'dotenv', '2.1.1'
  gem 'thin', '1.7.0'
  gem 'json', '2.0.1'
  gem 'rubocop', '0.41.1', require: false
  gem 'rufus-scheduler', '3.2.1'
  gem 'logging', '2.1.0'
end

# Development
group :development do
  gem 'sqlite3', '1.3.11'
end

# Production
group :production do
  gem 'pg', '0.18.4'
  gem 'mysql', '2.9.1'
  gem 'unicorn'
end

# Testing
group :test, :development do
  gem 'sqlite3', '1.3.11'
  gem 'rspec', '3.5.0'
  gem 'bacon', '1.2.0'
  gem 'rack-test', '0.6.3'
  gem 'factory_girl', '4.7.0'
  gem 'pg', '0.18.4'
  gem 'mysql', '2.9.1'
end
