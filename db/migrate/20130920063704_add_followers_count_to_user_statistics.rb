class AddFollowersCountToUserStatistics < ActiveRecord::Migration
  def change
    add_column :user_statistics, :followers_count, :integer
  end
end
