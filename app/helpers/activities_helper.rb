module ActivitiesHelper
  def timeline_date(activity)
    activity.created_at.strftime "%R"
  end

  def owner_link(activity)
    case activity.owner
      when Customer
        haml_concat link_to \
          activity.owner.name,
          customer_path(activity.owner)

      when Agent
        haml_concat link_to \
          activity.owner.name,
          agent_path(activity.owner)
    end
  end

  def link_to_request(activity)
    haml_tag :b do
      haml_concat link_to "##{activity.trackable.id}",
        team_request_path(current_team, activity.trackable.number)
    end
  end

  def request_name(activity, tag=:small)
    return if activity.trackable.name.blank?

    haml_tag tag do
      haml_concat truncate(activity.trackable.name, length:40)
    end
  end
  
  def email_content(email)
    email.message.html.
      gsub!(/\<img.*mandrillapp.com\/track.*\>/, '').
      html_safe
  end
end
