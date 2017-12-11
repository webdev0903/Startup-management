require 'csv'

module Migrators
  module Notifications

    class << self

      BATCH_SIZE = 1000
    
      def import!
        notifications = []
        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/notifications.csv', :headers => true) do |row|
          row = row.to_hash
          row['follower_id'] = row['startup_follower_id'].blank? ? row['user_following_id'] : row['startup_follower_id']
          row.reject!{ |k,v| %w[id is_emailed group_user_id startup_follower_id user_following_id group_post_id
            question_id question_answer_id question_vote_id question_follower_id user_recommendation_id].include? k }
          notifications << Notification.new(row)
          if notifications.size > BATCH_SIZE
            Notification.import notifications, :validate => false
            notifications = []
          end
        end
        Notification.import notifications, :validate => false
      end

    end

  end
end