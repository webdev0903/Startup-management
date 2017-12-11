class ScheduledNotificationEmail
  
  def initialize(options={})
    @users = options[:user_ids].present? ? User.where('users.id IN (?)', options[:user_ids]) : []
    @debug = options[:debug] || false  
    @log = Logger.new(Rails.root.join('log', 'scheduled_job_morning_mail.log'))
  end

  def send_morning_mail
    @users = @users.present? ? @users : User.ready_for_morning_mail
    @users = @users.includes(:notifications).where('notifications.id IS NOT NULL AND notifications.read IS false').references(:notifications)
    @tried_processing = true
    @users = @users.sample(2) if @debug    
    @users.each do |user|
      @log.info('=== Start sending morning mail for #{user.title} ===')
      begin
        if NotificationMailer.morning_email(user.notifications, {:debug => @debug} ).deliver
          if !@debug
            user.notifications.update_all(read: true)
            user.setting.update_attribute(:next_email_at, Time.now + 3.hours)
          end
        end
        @log.info('Success')
      rescue => e
        ExceptionNotifier.notify_exception(e, :data => { user: user, notifications: user.notifications })
        @log.info('Error')
      end
      @log.info("=== End for #{user.title} ==='")
    end
  end

  def report
    return @users.map{|u| {u.id => u.notifications.to_a} } if @tried_processing
    []
  end
end