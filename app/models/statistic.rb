class Statistic < ActiveRecord::Base
  belongs_to :owner, polymorphic:true
  
  class Reply < self
  end
  
  class Close < self
  end
end
