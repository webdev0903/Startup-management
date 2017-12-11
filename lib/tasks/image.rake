require 'fuzzy_match'

namespace :images do
  task :clear_startups => :environment do
    startups = Startup.all
    startups.each do |startup|
      if startup.lagacy_photo.nil?
        puts "#{startup.title} not using Lagacy Photo."
      else
        result = FileTest.exist?("http://starterpad.com/photos/122.#{startup.lagacy_photo}")
        if result == true
          puts "#{startup.title} using Lagacy Photo."
        else
          puts "#{startup.title} using Lagacy Photo, but not exists."
          #startup.update_attribute(:lagacy_photo, nil)
        end
      end      
    end
  end

  task :clear_groups => :environment do
    groups = Group.all
    groups.each do |group|
      if group.lagacy_photo.nil?
        puts "#{group.title} not using Lagacy Photo."
      else
        result = FileTest.exist?("http://starterpad.com/photos/122.#{group.lagacy_photo}")
        if result == true
          puts "#{group.title} using Lagacy Photo."
        else
          puts "#{group.title} using Lagacy Photo, but not exists."
          #group.update_attribute(:lagacy_photo, nil)
        end
      end      
    end
  end

  task :clear_users => :environment do
    users = User.all
    users.each do |user|
      if user.lagacy_photo.nil?
        puts "#{startup.title} not using Lagacy Photo."
      else
        result = FileTest.exist?("http://starterpad.com/photos/122.#{user.lagacy_photo}")
        if result == true
          puts "#{user.title} using Lagacy Photo."
        else
          puts "#{user.title} using Lagacy Photo, but not exists."
          #user.update_attribute(:lagacy_photo, nil)
        end
      end      
    end
  end




end
