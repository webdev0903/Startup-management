class RemoveUserIdAndStartupIdFromCofounders < ActiveRecord::Migration
  def change
  	remove_column :cofounders, :user_id
  	remove_column :cofounders, :startup_id
  end
end
