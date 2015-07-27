# TODO: refactor to view object / presenter / decorator - e.g.
# require 'delegate'
# class RequestActivity < SimpleDelegator
#   def icon
#     ...
# activity = RequestActivity.new @request, dashboard:false

module ActivitiesHelper
  def timeline_icon(activity)
    case activity.key
      when /request.open/
        haml_tag 'i.fa.fa-envelope.bg-red'
      when /request.reply/
        haml_tag 'i.fa.fa-mail-reply.bg-teal'
      when /request.comment/
        haml_tag 'i.fa.fa-comment-o'
      when /request.assign/
        haml_tag 'i.fa.fa-user-plus.text-yellow'
      when /request.label/
        haml_tag 'i.fa.fa-tags'
      when /request.close/
        haml_tag 'i.fa.fa-check.bg-green'
      when /guide\.\w+/
        haml_tag 'i.fa.fa-book'
      else
        haml_tag 'i.fa.fa-cogs'
    end
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

  def description(activity, dashboard=true)
    case activity.key
      when /request\.open/
        activity_description 'opened'
        request_summary activity, dashboard

      when /request.reply/
        activity_description 'replied'
        request_summary activity, dashboard

      when /request.comment/
        activity_description 'commented on'
        request_summary activity, dashboard

      when /request.assign/
        activity_description  'assigned'
        haml_concat link_to \
          activity.recipient.name,
          agent_path(activity.recipient)
        haml_concat 'to ' if dashboard
        request_summary activity, dashboard

      when /request.label$/
        activity_description 'labeled'
        request_summary activity, dashboard

        haml_tag 'span.text-muted' do
          haml_concat 'as'
        end

        [ activity.parameters['label'] ].flatten.each do |label|
          haml_concat link_to \
            label,
            team_requests_path(current_team, q:{label:label}),
            class:'btn btn-xs bg-info'
          end

      when /request.label.remove/
        activity_description 'removed label'
        request_summary activity, dashboard

        [ activity.parameters['label'] ].flatten.each do |label|
          haml_concat link_to \
            label,
            team_requests_path(current_team, q:{label:label}),
            class:'btn btn-xs bg-info'
          end

      when /request.rename/
        activity_description 'renamed'
        link_to_request activity if dashboard
        haml_tag('s.text-muted') { haml_concat activity.parameters['from'] }
        haml_tag(:b) { haml_concat activity.parameters['to'] }

      when /request.happiness/
        activity_description 'updated happiness'
        request_summary activity, dashboard
        haml_tag('s.text-muted') { haml_concat activity.parameters['was'] }
        haml_tag(:b) { haml_concat activity.parameters['now'] }
        haml_tag :sup, '%'

      when /request.close/
        activity_description 'closed'
        request_summary activity, dashboard

      when /request.reopen/
        activity_description 're-opened'
        request_summary activity, dashboard

      when /request.notes/
        activity_description 'updated notes'
        request_summary activity, dashboard

      when /guide\.create/
        activity_description 'created guide'
        haml_concat link_to activity.trackable.name,
          guide_path(current_team, activity.trackable)

      when /guide\.update/
        activity_description 'updated guide'
        haml_concat link_to activity.trackable.name,
          guide_path(current_team, activity.trackable)

      when /guide\.delete/
        activity_description 'deleted guide'
        haml_tag :s do
          haml_concat activity.parameters['deleted_guide_name']
        end
    end
  end

  def timeline_body(activity)
    case activity.key
      when /request\.open/
        haml_tag_timeline_body activity
      when /request\.reply/
        haml_tag_timeline_body activity
      when /request\.comment/
        haml_tag_timeline_body activity
    end
  end

  private

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

  def activity_description(text, tag='span.text-muted')
    haml_tag tag do
      haml_concat text
    end
  end

  def request_summary(activity, dashboard)
    return unless dashboard
    link_to_request activity
    request_name activity
  end

  def haml_tag_timeline_body(activity, dashboard=false)
    return unless activity.parameters.present?

    # TODO: refactor to more elegant solution
    summary = if activity.parameters.has_key?('email_id')
      email = Email.find(activity.parameters['email_id'])
      dashboard ? email.message.text : email.message.html
    elsif activity.parameters.has_key?('comment')
      activity.parameters['comment']
    end

    haml_tag('.timeline-body') { haml_concat(summary) } if summary.present?
  end
end
