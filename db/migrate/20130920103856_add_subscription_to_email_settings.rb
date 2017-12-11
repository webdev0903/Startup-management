class AddSubscriptionToEmailSettings < ActiveRecord::Migration
  def change
    add_column :email_settings, :subscription, :boolean
  end
end
