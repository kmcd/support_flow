source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'pg'
gem 'haml-rails', '~> 0.8'
gem 'public_activity'
gem 'delayed_job_active_record'
gem 'acts-as-taggable-array-on' # TODO: replace with (table/array)
gem 'elasticsearch'
gem 'mini_magick'
gem 'clockwork'

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'guard-zeus'
end

group :development do
  gem 'guard'
  gem 'guard-bundler', require: false
  gem 'guard-rails'
  gem 'guard-livereload', '~> 2.4', require: false
  gem 'looksee'
  gem 'awesome_print'
end

group :test do
  gem 'minitest-reporters'
  gem 'mocha'
  gem 'test_after_commit'
end

group :production do
  gem 'shelly-dependencies'
end
