module Profileable
  def name
    Faker::Name.name
  end
  
  def avatar
    Faker::Avatar.image
  end
end
