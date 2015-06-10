class Activity < ActiveRecord::Base
  belongs_to :team

  with_options polymorphic:true do |activity|
    activity.belongs_to :owner
    activity.belongs_to :recipient
    activity.belongs_to :trackable
  end
end
