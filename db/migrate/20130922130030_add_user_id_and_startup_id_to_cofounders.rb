class AddUserIdAndStartupIdToCofounders < ActiveRecord::Migration
  def change
    add_column :cofounders, :user_id, :integer
    add_column :cofounders, :startup_id, :integer
  end
end
