class Email < ActiveRecord::Base
  belongs_to :request
  composed_of :message, mapping: %w[ payload ]
  
  delegate *%i[ to from subject text ], to: :message
end
