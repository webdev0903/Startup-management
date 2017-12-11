class RemoveMaxDailyTweets < ActiveRecord::Migration
  def change
    remove_column :user_parameters, :max_daily_tweets
  end
end
