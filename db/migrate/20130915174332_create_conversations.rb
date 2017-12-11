class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.integer :user_id
      t.integer :recipient_id
      t.datetime :last_action_at
      t.boolean :new
      t.integer :private_message_id
      t.boolean :user_hide
      t.boolean :recipient_hide

      t.timestamps
    end
  end
end
