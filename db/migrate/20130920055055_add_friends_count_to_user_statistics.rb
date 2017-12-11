class AddFriendsCountToUserStatistics < ActiveRecord::Migration
  def change
    add_column :user_statistics, :friends_count, :integer
  end
end
