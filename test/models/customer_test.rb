require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  test "name profile" do
    name = 'peldi guizzoni'
    @peldi.update name:name
    
    assert_equal name, @peldi.reload.name
  end
  
  test "company profile" do
    company = 'balsamiq'
    @peldi.update name:'peldi', company:company
    
    assert_equal company, @peldi.reload.company
  end
  
  test "phone profile" do
    phone = '088233'
    @peldi.update phone:phone
    
    assert_equal phone, @peldi.reload.phone
  end
  
  test "notes profile" do
    notes = <<-NOTES.strip_heredoc.strip_heredoc
      going on holidays ...
    NOTES
    @peldi.update notes:notes
    
    assert_equal notes, @peldi.reload.notes
  end
end
