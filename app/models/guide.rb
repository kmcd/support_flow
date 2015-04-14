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
    name =~  /^(_template|index)$/ ? false : true
  end
end
