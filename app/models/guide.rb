class Guide < ActiveRecord::Base
  include Indexable
  belongs_to :team
  validates :name, presence:true
  validates :name, uniqueness:{ scope: :team }
  validate :name_contains_no_slashes
  
  def self.pages(team)
    [
      where(name:'index').first,
      where(team:team).
        where.not(name:'_template').
        where.not(name:'index').
        order(:name)
    ].flatten
  end
  
  def self.template(team)
    where( team:team, name:'_template' ).first
  end
  
  def self.index(team)
    where( team:team, name:'index' ).first
  end
  
  def deleteable?
    !( home_page? || template? )
  end
  
  def created_activity
    activities.where(key:'guide.create').first
  end
  
  def updated_activity
    activities.where(key:'guide.update').last
  end
  
  def home_page?
    name == 'index'
  end

  def template?
    name == '_template'
  end
  
  def text_content
    Nokogiri::HTML(content).text
  end
  
  private
  
  # TODO: change to has_many
  def activities
    @activities ||= Activity.where trackable:self
  end
  
  def name_contains_no_slashes
    errors[:name] << "forward slash prohibited" if /\//.match name
    errors[:name] << "back slash prohibited" if /\\/.match name
  end
end
