source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'pg'
gem 'haml-rails', '~> 0.8'
gem 'textacular', '~> 3.0'
gem 'griddler-mandrill'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :development do
  # gem 'rack-mini-profiler', require: false
  gem 'guard'
  gem 'guard-bundler', require: false
  gem 'guard-rails'
  gem 'guard-livereload', '~> 2.4', require: false
  gem 'guard-minitest'
  gem 'faker'
  gem 'commands'
  gem 'looksee'
end

group :test do
  gem 'minitest-reporters'
  gem 'mocha'
end

group :production do
  gem 'shelly-dependencies'
end
