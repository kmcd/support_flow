source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'pg'
gem 'rails-observers'
gem 'activerecord-session_store'
gem 'delayed_job_active_record'
gem 'will_paginate' # N.B. pagination must precede elasticsearch
gem 'elasticsearch'
gem 'elasticsearch-rails'
gem 'elasticsearch-model'
gem 'elasticsearch-dsl'
gem 'clockwork'
gem 'griddler'
gem 'timecop'
gem 'dalli'
gem 'jquery-rails'
gem 'haml-rails'
gem 'mini_magick'
gem 'browser-timezone-rails'
gem 'remotipart', '~> 1.2'
gem 'htmlbeautifier'

group :development do
  gem 'looksee'
  gem 'awesome_print'
  gem 'guard'
  gem 'guard-bundler', require: false
  gem 'guard-rails'
  gem 'guard-livereload', '~> 2.4', require: false
  gem 'spring'
end

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
end

group :development, :production do
  gem 'sass-rails'
  gem 'uglifier'
  gem 'coffee-rails'
  gem 'faker'
  gem 'launchy'
end

group :test do
  gem 'minitest-reporters'
  gem 'test_after_commit'
  gem 'mocha'
end

group :production do
  gem 'shelly-dependencies'
end
