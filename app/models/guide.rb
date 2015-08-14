class Guide < ActiveRecord::Base
  include Indexable
  attr_accessor :current_agent
  validates :name, presence:true
  validates :name, uniqueness:{ scope: :team }
  before_save :generate_slug
  after_create ->() { activity_timeline :create }
  after_update ->() { activity_timeline :update }
  belongs_to :team

  # TODO: move to scopes
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

  # TODO: move to Guide scope
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

  # TODO: move to has_many :activities
  def activities
    Activity.where trackable:self
  end

  def generate_slug
    self.slug = name.parameterize
  end
  
  def activity_timeline(key)
    Activity.create \
      key:"guide.#{key.to_s}",
      trackable:self,
      owner:current_agent,
      team:team
  end
end
