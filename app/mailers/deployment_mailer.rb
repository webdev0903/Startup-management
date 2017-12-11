class DeploymentMailer < ActionMailer::Base

  default from: "StarterPad <deployments@starterpad.com>"

  def status(body)
    mail :to => 'kane.web.marketing@gmail.com', :cc => 'rezatxe@gmail.com', :subject => 'Deployment Status of [starterpad.com]', :body => body
  end
end
