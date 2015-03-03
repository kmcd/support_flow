require 'rails/generators/active_record'

class PoroGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :attributes, :type => :array, :default => []
  
  # TODO: add USAGE documentation
  # TODO: Add generator options
  # Options:
  # -> don't create test file
  # -> create outside app
  # -> specify file extension
  # -> delete files
  def create_ruby_test_files
    create_directories
    template "poro.erb", ruby_template
    template "poro_test.erb", test_template
  end
  
  private
  
  def create_directories
    return unless namespaced?
    empty_directory "lib/#{directory_path}"
    empty_directory "test/#{directory_path}"
  end
  
  def ruby_template
    if namespaced?
      "lib/#{directory_path}/#{ruby_file}.rb"
    else
      "lib/#{ruby_file}.rb"
    end
  end
  
  def test_template
    if namespaced?
      "test/lib/#{directory_path}/#{ruby_file}_test.rb"
    else
      "test/lib/#{ruby_file}_test.rb"
    end
  end
  
  def namespaced?
    directories.any?
  end
  
  def file_path
    file_name.split /\//
  end
  
  def ruby_file
    file_path.last
  end
    
  def directories
    file_path[0..-2]
  end
  
  def directory_path
    directories.join '/'
  end
  
  def class_name
    namespaced? ? file_name.camelize : ruby_file.classify
  end
  
  def file_name
    attributes.first
  end
end
