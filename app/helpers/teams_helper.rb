module TeamsHelper
  def pluralized(open_requests)
    request_text = "request"
    open_requests > 1 ? request_text.pluralize : request_text
  end

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
      when /request.rename/
        haml_tag 'i.fa.fa-cogs'
      when /request.merge/
        haml_tag 'i.fa.fa-cogs'
      when /request.close/
        haml_tag 'i.fa.fa-check.bg-green'
      when /guide\.\w+/
        haml_tag 'i.fa.fa-book'
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

  def description(activity)
    case activity.key
      when /request\.open/
        activity_description 'opened'
        link_to_request activity

      when /request.reply/
        activity_description 'replied to'
        link_to_request activity
        request_name activity

      when /request.comment/
        activity_description 'commented on'
        link_to_request activity
        request_name activity

      when /request.assign/
        activity_description  'assigned'
        haml_concat link_to \
          activity.recipient.name,
          agent_path(activity.recipient)
        haml_concat 'to '
        link_to_request activity
        request_name activity

      when /request.label/
        activity_description 'labeled'
        link_to_request activity
        request_name activity
        haml_tag 'span.text-muted' do
          haml_concat 'as'
        end
        haml_concat link_to \
          activity.parameters['label'],
          '/search?q=label:urgent',
          class:'btn btn-xs bg-info'

      when /request.rename/
        activity_description 'renamed'
        link_to_request activity
        haml_tag(:span) { haml_concat activity.parameters['to'] }
        haml_tag('s.text-muted') { haml_concat activity.parameters['from'] }

      when /request.merge/
        activity_description 'merged'
        link_to_request activity
        request_name activity
        haml_concat 'with'
        haml_tag('s.text-muted') do
          haml_concat "##{activity.recipient.id}"
          haml_concat activity.parameters['merged_request_name']
        end

      when /request.close/
        activity_description 'closed'
        link_to_request activity
        request_name activity

      when /guide\.create/
        activity_description 'created guide'
        haml_concat link_to activity.trackable.name,
          guide_path(activity.trackable)

      when /guide\.update/
        activity_description 'updated guide'
        haml_concat link_to activity.trackable.name,
          guide_path(activity.trackable)

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
        haml_tag '.timeline-body' do
          # TODO: use email message if name not present
          haml_concat activity.parameters['message']
        end
      when /request\.reply/
        haml_tag '.timeline-body' do
          haml_concat activity.parameters['message']
        end
      when /request\.comment/
        haml_tag '.timeline-body' do
          haml_concat activity.parameters['comment']
        end
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
end
