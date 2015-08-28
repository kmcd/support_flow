class Statistic < ActiveRecord::Base
  belongs_to :owner, polymorphic:true
  
  def self.owned_by(owner)
    where(owner:owner).first_or_initialize
  end
  
  class Reply < self
    def seconds
      value.to_i
    end
  end
  
  class Close < self
    def seconds
      value.to_i
    end
  end
  
  class Happiness < self
  end
end
