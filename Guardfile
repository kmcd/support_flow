interactor :off
logger device: 'guard.log'

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new

  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end

guard :rails, daemon: true do
  watch('Gemfile.lock')
  watch(%r{^(config|lib)/.*})
end

guard :livereload do
  watch(%r{app/assets/.+\.(css|js|html)})
  watch(%r{app/controllers/.+\.rb})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{app/lib/.+\.rb})
  watch(%r{app/models/.+\.rb})
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{config/locales/.+\.yml})
  watch(%r{lib/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
end

guard :zeus, rspec:false, test_unit:true, run_all:false do
end
