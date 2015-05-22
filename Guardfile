interactor :off
logger device: 'guard.log'

guard 'rails', daemon: true do
  watch('Gemfile.lock')
  watch(%r{^(config|lib)/.*})
end

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
end

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new

  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end

guard 'zeus', rspec:false, test_unit:true, run_all:true   do                  
  # TestUnit
  watch(%r|^test/(.*)_test\.rb$|)
  watch(%r|^lib/(.*)([^/]+)\.rb$|)     {|m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r|^test/test_helper\.rb$|)    { "test" }
  watch(%r|^app/controllers/(.*)\.rb$|) \
    {|m| "test/controllers/#{m[1]}_test.rb" }
  watch(%r|^app/models/(.*)\.rb$|)  {|m| "test/unit/#{m[1]}_test.rb" }
  watch(%r|^app/lib/(.*)\.rb$|)     {|m| "test/unit/#{m[1]}_test.rb" }
  watch(%r|^app/jobs/(.*)\.rb$|)    {|m| "test/unit/#{m[1]}_test.rb" }
  watch(%r|^app/mailers/(.*)\.rb$|) {|m| "test/unit/#{m[1]}_test.rb" }
end
