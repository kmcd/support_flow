module Statistics
  extend ActiveSupport::Concern
  
  def average_reply
    Statistic::Reply.owned_by(self).try &:value
  end
  
  def average_close
    Statistic::Close.owned_by(self).try &:value
  end
end
