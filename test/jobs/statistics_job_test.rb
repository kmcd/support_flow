require 'test_helper'

class StatisticsJobTest < ActiveJob::TestCase
  def setup
    Statistic.delete_all
  end

  def days_in_seconds(number=1)
    number * 86_400
  end
  
  test "team reply" do
    Activity.create trackable:@billing_enquiry,
      key:'request.reply_time', parameters:{ time:days_in_seconds(5) }
    StatisticsJob.perform_now
    
    assert_equal days_in_seconds(5), Statistic::Reply.
      where(owner:@support_flow).first.value.to_i
    
    Activity.create trackable:@duplicate_enquiry,
      key:'request.reply_time', parameters:{ time:days_in_seconds(10)}
    StatisticsJob.perform_now
    
    assert_equal days_in_seconds(7.5), Statistic::Reply.
      where(owner:@support_flow).first.value.to_i
  end
  
  test "team close" do
    Activity.create trackable:@billing_enquiry,
      key:'request.close_time', parameters:{ time:days_in_seconds(5) }
    StatisticsJob.perform_now
    
    assert_equal days_in_seconds(5), Statistic::Close.
      where(owner:@support_flow).first.value.to_i
    
    Activity.create trackable:@duplicate_enquiry,
      key:'request.close_time', parameters:{ time:days_in_seconds(10)}
    StatisticsJob.perform_now
    
    assert_equal days_in_seconds(7.5), Statistic::Close.
      where(owner:@support_flow).first.value.to_i
  end
  
  test "agent reply" do
    Activity.create trackable:@billing_enquiry, owner:@rachel,
      key:'request.reply_time', parameters:{ time:days_in_seconds(5) }
    StatisticsJob.perform_now
    
    assert_equal days_in_seconds(5), Statistic::Reply.
      where(owner:@rachel).first.value.to_i
    
    Activity.create trackable:@billing_enquiry, owner:@rachel,
      key:'request.reply_time', parameters:{ time:days_in_seconds(10) }
    StatisticsJob.perform_now
    
    assert_equal days_in_seconds(7.5), Statistic::Reply.
      where(owner:@rachel).first.value.to_i
  end
  
  test "agent close" do
    Activity.create trackable:@billing_enquiry, owner:@rachel,
      key:'request.close_time', parameters:{ time:days_in_seconds(5) }
    StatisticsJob.perform_now
    
    assert_equal days_in_seconds(5), Statistic::Close.
      where(owner:@rachel).first.value.to_i
    
    Activity.create trackable:@billing_enquiry, owner:@rachel,
      key:'request.close_time', parameters:{ time:days_in_seconds(10) }
    StatisticsJob.perform_now
    
    assert_equal days_in_seconds(7.5), Statistic::Close.
      where(owner:@rachel).first.value.to_i
  end
  
  test "customer reply" do
    Activity.create trackable:@billing_enquiry,
      recipient:@peldi, key:'request.reply_time', 
      parameters:{ time:days_in_seconds(5) }
    StatisticsJob.perform_now
    
    assert_equal days_in_seconds(5), Statistic::Reply.
      where(owner:@peldi).first.value.to_i
    
    Activity.create trackable:@billing_enquiry, 
      recipient:@peldi, key:'request.reply_time', 
      parameters:{ time:days_in_seconds(10) }
    StatisticsJob.perform_now
    
    assert_equal days_in_seconds(7.5), Statistic::Reply.
      where(owner:@peldi).first.value.to_i
  end
  
  test "customer close" do
    Activity.create trackable:@billing_enquiry, 
      recipient:@peldi, key:'request.close_time', 
      parameters:{ time:days_in_seconds(5) }
    StatisticsJob.perform_now
    
    assert_equal days_in_seconds(5), Statistic::Close.
      where(owner:@peldi).first.value.to_i
    
    Activity.create trackable:@billing_enquiry, 
      recipient:@peldi, key:'request.close_time', 
      parameters:{ time:days_in_seconds(10) }
    StatisticsJob.perform_now
    
    assert_equal days_in_seconds(7.5), Statistic::Close.
      where(owner:@peldi).first.value.to_i
  end
end
