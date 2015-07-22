class Email < ActiveRecord::Base
  belongs_to  :sender, polymorphic:true
  belongs_to  :team
  belongs_to  :request
  has_many    :attachments
  scope :inbound, ->() { where type:'Email::Inbound' }
  scope :outbound, ->() { where type:'Email::Outbound' }
  composed_of :recipient_list, mapping:%w[ recipients ]
end
