require 'fuzzy_match'

namespace :startups do
  task :refresh_followers => :environment do
    startups = Startup.all
    startups.each do |startup|
      begin
        if startup.statistic
          followers_count = startup.followers.count
          startup.statistic.update_attribute(:followers_count, followers_count)
          Rails.logger.info "Statistic updated - #{startup.title}"
          puts("Statistic updated - #{startup.title}")
        else
          followers_count = startup.followers.count
          Startup::Statistic.create({:startup_id => startup.id, :followers_count => followers_count})
          Rails.logger.info "Statistic added. #{startup.title} "
          puts("Statistic added. #{startup.title} ")
        end

      rescue => e
        Rails.logger.error "Error: Startup not updated. #{startup.title} "
        puts("Error: Startup not updated. #{startup.title} ")
        Rails.logger.error e.message
        Rails.logger.debug e.backtrace.join("\n")
      end
    end
  end




end
