source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'pg'
gem 'jquery-rails'
gem 'haml-rails'
gem 'delayed_job_active_record'
gem 'acts-as-taggable-array-on' # TODO: replace with (table/array)
gem 'elasticsearch'
gem 'mini_magick'
gem 'clockwork'
gem 'faker'

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'guard-zeus'
end

group :development do
  gem 'looksee'
  gem 'awesome_print'
  gem 'guard'
  gem 'guard-bundler', require: false
  gem 'guard-rails'
  gem 'guard-livereload', '~> 2.4', require: false
end

group :test do
  gem 'minitest-reporters'
  gem 'mocha'
  gem 'test_after_commit'
end

group :development, :production do
  gem 'sass-rails'
  gem 'uglifier'
  gem 'coffee-rails'
end

group :production do
  gem 'shelly-dependencies'
end
