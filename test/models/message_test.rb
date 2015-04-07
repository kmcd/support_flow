require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  def setup
    @message = Message.create! content:Griddler::Email.new(
      from:'peldi@balsamiq.com', 
      to: %w[ help@getsupportflow.com ],
      subject:'help', 
      text:'please' )
  end
  
  test "set subject for searching" do
    assert_equal 'help', @message.reload.subject
  end
  
  test "set body for searching" do
    assert_equal 'please', @message.reload.text_body
  end
end
