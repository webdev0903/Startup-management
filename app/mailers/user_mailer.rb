class UserMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  default from: "StarterPad <support@starterpad.com>"

  def review_profile(user_id)
    @user = User.find user_id
    mail :to => @user.email, :subject => "Sorry to tell ya, but your profile needs improvement"
  end

  def active_profile(user_id)
  	@user = User.find user_id
    mail :to => @user.email, :subject => "Account Activated!"
  end

  def new_message(message)
    @message = message  	  	  	
  	mail :to => message.receiver.email, :subject => "New Message: #{truncate(message.text.squish, :lenght=>25, :escape=> false)}"
  end
end
