module Profileable
  def name
    ( profile && profile['name'] ) || email_address
  end
  
  def avatar
  end
end
