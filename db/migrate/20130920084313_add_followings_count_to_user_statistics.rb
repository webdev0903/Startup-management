class AddFollowingsCountToUserStatistics < ActiveRecord::Migration
  def change
    add_column :user_statistics, :followings_count, :integer
  end
end
