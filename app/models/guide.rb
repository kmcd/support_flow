class Guide < ActiveRecord::Base
  attr_accessor :current_agent
  validates :name, presence:true
  validates :name, uniqueness:{ scope: :team }
  belongs_to :team
  has_many :activities, as: :trackable
  before_save :indent_template

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

  def indent_template
    return unless template?

    self.content = HtmlBeautifier.beautify(content)
  end
end
