class Guide < ActiveRecord::Base
  belongs_to :team
  validates :name, presence:true
  validates :name, uniqueness:{ scope: :team }
  validate :name_contains_no_slashes
  
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
  
  # TODO: change
  def activities
    @activities ||= Activity.where trackable:self
  end
  
  def name_contains_no_slashes
    errors[:name] << "forward slash prohibited" if /\//.match name
    errors[:name] << "back slash prohibited" if /\\/.match name
  end
end
