class AddCofounderIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :cofounder_id, :integer
  end
end
