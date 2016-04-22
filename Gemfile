source 'https://rubygems.org'
ruby '2.3.0'

# Default
group :default do
  # Sinatra
  gem 'sinatra', require: 'sinatra/base'
  gem 'rake'

  # Database
  gem 'sequel'
  gem 'sinatra-sequel'

  # Tools
  gem 'dotenv'
  gem 'thin'
  gem 'json'
  gem 'redis', '~>3.2'
  gem 'rubocop', require: false
end

# Development
group :development do
  gem 'sqlite3'
  # gem 'pg'
end

# Production
group :production do
  gem 'pg'
end

# Testing
group :test, :development do
  gem 'sqlite3'
  gem "rspec"
  gem "rack-test"
  gem "factory_girl"
end