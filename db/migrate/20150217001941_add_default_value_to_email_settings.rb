class AddDefaultValueToEmailSettings < ActiveRecord::Migration
  def up
	  change_column :email_settings, :morning_mail, :boolean, :default => true
	  change_column :email_settings, :private_messages, :boolean, :default => true
	  change_column :email_settings, :subscription, :boolean, :default => true
	end

	def down
	  change_column :email_settings, :morning_mail, :boolean, :default => false
	  change_column :email_settings, :private_messages, :boolean, :default => false
	  change_column :email_settings, :subscription, :boolean, :default => false
	end
end
