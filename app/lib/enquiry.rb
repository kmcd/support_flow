class Enquiry
  include ActiveModel::Model
  attr_accessor :message
  validates :message, presence: true
  validate :mailbox_exists
  validate :new_request
  
  def save
    return unless valid?
    
    # find or create customer record
    # Customer.find_or_create email:'', team:''
    
    # find team mail box
    
    # create customer request
    # persisted? -> true
  end
  
  private
  
  def mailbox_exists
  end
  
  def new_request
  end
end