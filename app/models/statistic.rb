class Statistic < ActiveRecord::Base
  belongs_to :owner, polymorphic:true
  
  def self.owned_by(owner)
    where(owner:owner).first_or_initialize
  end
  
  def time
    value.to_i / 60
  end
  
  class Reply < self
  end
  
  class Close < self
  end
  
  class Happiness < self
  end
end
