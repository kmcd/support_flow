module RequestsHelper
  def open_since
    [ rand(10).to_s + 'd',
      rand(1..24).to_s  + 'h',
      rand(1..60).to_s  + 'm' ].join ' '
  end
  
  def avatar
    return Faker::Avatar.image if rand(0..1) == 0
    'https://avatars1.githubusercontent.com/u/8568?v=3&s=460'
  end
end
