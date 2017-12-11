class AddGoogleToEmailSettings < ActiveRecord::Migration
  def change
    add_column :email_settings, :google, :boolean
  end
end
