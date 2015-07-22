require 'test_helper'

class AgentMailerTest < ActionMailer::TestCase
  test "reply" do
    skip
    mail = AgentMailer.reply
    assert_equal "Reply", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
