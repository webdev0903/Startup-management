class SupportMailer < ActionMailer::Base

  default to: "support@starterpad.com"

  def inform_support(contact)
    @contact = contact
    mail :from => @contact.email, :subject => @contact.subject
  end
end
