namespace :database do
  desc "Reset counter cache"
  task reset_counters: :environment do
  	# reset counter
    User::Statistic.find_each { |stat|
      ActiveRecord::Base.connection.exec_query("update user_statistics set friends_count = 0, followings_count = 0, followers_count = 0 where id = #{stat.id} ")
      User::Statistic.update_counters stat.id, followers_count:  stat.user.followers.where("users.status = 't'").count
      User::Statistic.update_counters stat.id, followings_count: stat.user.followings.where("users.status = 't'").count
      User::Statistic.update_counters stat.id, friends_count:    stat.user.friends.where("users.status = 't'").count
    }
  end

  desc "Remove Orphan records"
  task remove_orphans: :environment do
    # delete all orphan notifications
    Notification.where('user_id not in (?)', User.pluck(:id)).destroy_all

    # user stats delete
    User::Statistic.where('user_id not in (?)', User.pluck(:id)).destroy_all

    Friendship.where('user_id not in (?)', User.pluck(:id)).destroy_all
    
    Followership.where('user_id not in (?)', User.pluck(:id)).destroy_all

    Followership.where('user_id not in (?)', User.pluck(:id)).destroy_all

    Followership.where('recipient_id is not null and recipient_id not in (?)', User.pluck(:id)).destroy_all

    Comment.where('user_id not in (?)', User.pluck(:id)).destroy_all
  end

  desc "Update Activable Column"
  task update_activable: :environment do
    User.is_complete.readonly(false).each { |u|
      u.activable = true 
      u.save
    }
  end

  desc "Fix Timezone identifiers"
  task fix_timezone: :environment do
    ActiveSupport::TimeZone.all.each do |tz|
      User.where('timezone = ?', tz.tzinfo.identifier).update_all(timezone: tz.name)  
    end
    mapping = {
      'America/Havana' => 'Eastern Time (US & Canada)',
      'Asia/Beirut' => 'Baghdad',
      'America/Campo_Grande' => 'Georgetown',
      'Asia/Dubai' => 'Abu Dhabi',
      'America/Asuncion' => 'Santiago',
      'Atlantic/Stanley' => 'Montevideo',
      'America/Santa_Isabel' => 'Mazatlan',
      'America/Santo_Domingo' => 'La Paz',
      'Asia/Damascus' => 'Riyadh',
      'Asia/Omsk' => 'Krasnoyarsk ',
      'Asia/Gaza' => 'Baghdad',
      'Africa/Lagos' => 'West Central Africa',
      'America/Goose_Bay' => 'Greenland',
    }
    mapping.each do |key,val|
      User.where('timezone = ?', key).update_all(timezone: val)  
    end
  end
end


=begin

mina "run[cd current && RAILS_ENV=staging bundle exec rake database:remove_orphans ]"
mina "run[cd current && RAILS_ENV=staging bundle exec rake database:reset_counters ]"

=end
