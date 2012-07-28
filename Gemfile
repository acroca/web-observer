source 'https://rubygems.org'

gem 'rails', "~> 3.2"

gem 'json'
gem 'jquery-rails'
gem 'simple_form', "~> 2.0"
gem 'typhoeus', "~> 0.4"
gem 'nokogiri', '~> 1.5'

group :test do
  gem "rspec-rails", "~> 2.11"
  gem 'shoulda-matchers', "~> 1.2"
  gem 'factory_girl_rails', "~> 3.0"
  gem 'webmock', "~> 1.8"
end

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'twitter-bootstrap-rails', "~> 2.1"
end

group :development, :test do
  gem 'sqlite3'
end

group :production do
  gem 'pg'
  gem 'unicorn'
end