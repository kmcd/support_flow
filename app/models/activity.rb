class Activity < ActiveRecord::Base
  belongs_to :team

  with_options polymorphic:true do |activity|
    activity.belongs_to :owner
    activity.belongs_to :recipient
    activity.belongs_to :trackable
  end

  def email
    return unless parameters.try {|_| _.has_key? 'email_id' }

    Email::Inbound.find_by_id parameters['email_id']
  end
end
