class Guide < ActiveRecord::Base
  belongs_to :team
  validates :name, presence:true
  validates :name, uniqueness:{ scope: :team }
  
  def self.pages(team)
    where(team:team).
      where.not(name:'_template').
      where.not(name:'index').
      order(:name)
  end
  
  def self.template(team)
    where( team:team, name:'_template' ).first
  end
  
  def self.index(team)
    where( team:team, name:'index' ).first
  end
  
  def deleteable?
    name !~  /^(_template|index)$/
  end
  
  def created_activity
    activities.where(key:'guide.create').first
  end
  
  def updated_activity
    activities.where(key:'guide.update').last
  end
  
  private
  
  def activities
    @activities ||= Activity.where trackable:self
  end
end
