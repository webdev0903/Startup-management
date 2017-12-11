class ScheduledStartupAutoresponder
  
  def self.send(options = {})
    debug = options['debug'] || false   
    @days = options['days'] || 14
    @log = Logger.new(Rails.root.join('log', 'scheduled_startup_autoresponder.log'))
    @zones = self.lateMorningZones        

    @startups = Startup.
      select('startups.*'). # to avoid readonly error
      joins('LEFT JOIN "posts" ON "posts"."startup_id" = "startups"."id"').
      where('startups.created_at < ? ', Time.zone.now - @days.days).      
      group('startups.id').
      having('( MAX(posts.created_at) < ? or MAX(posts.created_at) is null ) AND ( startups.last_email_at < MAX(posts.created_at) or startups.last_email_at is null )', Time.zone.now - @days.days)

    @startups.readonly(false).each do |startup|
      @log.info("=== Start sending autoresponder email for #{startup.title} ===")
      begin   
        #check only if the owner timezone matched, don't care about timezones for cofounders
        owner_zone = startup.owner.timezone || 'Eastern Time (US & Canada)'
        if(@zones.include? owner_zone)
          startup.founders.each do |user|
            if(user.setting.startup_update_reminder)
              NotificationMailer.startup_autoresponder_email(startup,user, {:debug => @debug} ).deliver
            end
          end
          if !@debug
            startup.last_email_at = Time.zone.now
            startup.save()
          end
          @log.info('Success')
        end
      rescue => e
        ExceptionNotifier.notify_exception(e, :data => { startup: startup })
        @log.info("Error #{e}")
      end
    end      
  end

  def self.lateMorningZones
    hour = Time.now.in_time_zone('UTC').hour
    late_morning_zone = []
    WaktuSubuh.new.late_morning_zone(hour).each do |tz|
      late_morning_zone = late_morning_zone + WaktuSubuh.build_time_zone_list(:all, tz)
    end
    return late_morning_zone
  end
end
