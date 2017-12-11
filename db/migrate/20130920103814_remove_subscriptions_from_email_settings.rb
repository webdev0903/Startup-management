class RemoveSubscriptionsFromEmailSettings < ActiveRecord::Migration
  def change
  	remove_column :email_settings, :subscriptions
  end
end
