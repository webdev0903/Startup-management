class AddStarupUpdateReminderToEmailSettings < ActiveRecord::Migration
  def change
  	add_column :email_settings, :startup_update_reminder, :boolean, :default => true  	
  end
end
