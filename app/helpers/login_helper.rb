module LoginHelper
  def login_error?
    flash[:notice].to_s =~ /error/i
  end
end
