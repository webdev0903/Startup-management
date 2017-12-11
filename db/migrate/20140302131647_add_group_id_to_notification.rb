class AddGroupIdToNotification < ActiveRecord::Migration
  def change
    change_table :notifications do |t|
      t.references :group
    end
  end
end
