class NotificationMailer < ActionMailer::Base
  helper :notifications
  default from: "StarterPad <notifications@starterpad.com>"
  def morning_email(notifications, options={})
    @notifications = notifications
    @user = notifications.last.recipient
    if options[:debug]
      @to = 'rezatxe@gmail.com'
    else
      @to = @user.email
    end

    mail to: @to, subject: 'Morning Mail'
  end

  def startup_autoresponder_email(startup, user, options={})   
    @startup = startup
    @to = user.email
    mail to: @to, subject: "It's time to update your #{@startup.title} followers!"      
  end
end
