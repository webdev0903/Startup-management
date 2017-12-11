current_path = File.expand_path(File.dirname(__FILE__))
require current_path + '/../config/boot'
require current_path + '/../config/environment'
require 'clockwork'

Clockwork.every(2.seconds, 'Auto Tweet') do
  begin
    ScheduledTweet.new
  rescue => e
    ExceptionNotifier.notify_exception(e)
  end
end

Clockwork.every(1.hours, 'Schedule Morning Mail') do
	begin
    ScheduledNotificationEmail.new.send_morning_mail
  rescue => e
    ExceptionNotifier.notify_exception(e)
  end
end

Clockwork.every(1.hours, 'Startup Autoresponder Email') do
  begin 
    ScheduledStartupAutoresponder.send
  rescue => e
    ExceptionNotifier.notify_exception(e)
  end
end
