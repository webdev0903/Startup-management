class AddMaxDailyTweetToUserParameters < ActiveRecord::Migration
  def change
    add_column :user_parameters, :max_daily_tweets, :integer, default: 0
  end
end
