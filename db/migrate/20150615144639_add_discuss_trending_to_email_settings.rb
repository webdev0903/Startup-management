class AddDiscussTrendingToEmailSettings < ActiveRecord::Migration
  def change
  	add_column :email_settings, :discuss_trending, :boolean, :default => true
  end
end
