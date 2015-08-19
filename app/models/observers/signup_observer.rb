class SignupObserver < ActiveRecord::Observer
  observe :login
  
  def after_create(login)
    DemoJob.perform_later(login) if login.signup?
  end
end
