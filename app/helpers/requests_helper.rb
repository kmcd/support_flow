module RequestsHelper
  def open_since
    [ rand(10).to_s + 'd',
      rand(1..24).to_s  + 'h',
      rand(1..60).to_s  + 'm' ].join ' '
  end
end
