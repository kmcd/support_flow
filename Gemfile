source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'pg'
gem 'jquery-rails'
gem 'haml-rails'
gem 'delayed_job_active_record'
gem 'acts-as-taggable-array-on' # TODO: replace with acts_as_taggable
gem 'elasticsearch'
gem 'elasticsearch-rails'
gem 'elasticsearch-model'
gem 'elasticsearch-dsl'
gem 'mini_magick'
gem 'clockwork'

group :development do
  gem 'looksee'
  gem 'awesome_print'
  gem 'guard'
  gem 'guard-bundler', require: false
  gem 'guard-rails'
  gem 'guard-livereload', '~> 2.4', require: false
end

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'guard-zeus'
end

group :development, :production do
  gem 'sass-rails'
  gem 'uglifier'
  gem 'coffee-rails'
  gem 'faker'
end

group :test do
  gem 'minitest-reporters'
  gem 'test_after_commit'
  gem 'vcr'
end

group :production do
  gem 'shelly-dependencies'
end
