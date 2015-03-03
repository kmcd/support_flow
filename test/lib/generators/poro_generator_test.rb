require 'test_helper'
require 'generators/poro/poro_generator'

class PoroGeneratorTest < Rails::Generators::TestCase
  tests PoroGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
