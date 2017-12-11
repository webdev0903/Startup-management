class CreateEmailSettings < ActiveRecord::Migration
  def change
    create_table :email_settings do |t|
      t.integer :user_id
      t.boolean :private_messages
      t.boolean :morning_mail
      t.boolean :subscriptions
      t.datetime :last_email_at
      t.datetime :next_email_at
      t.integer :emails_count
      t.integer :admin_emails
      t.integer :confirmed_emails
      t.integer :welcome_emails
      t.string :hash_code

      t.timestamps
    end
  end
end
