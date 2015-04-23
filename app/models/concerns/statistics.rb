module Statistics
  extend ActiveSupport::Concern
  
  def average_reply
    Statistic::Reply.where(owner:self).first.try &:value
  end
  
  def average_close
    Statistic::Close.where(owner:self).first.try &:value
  end
end
