class CreatePrivateMessages < ActiveRecord::Migration
  def change
    create_table :private_messages do |t|
      t.integer :user_id
      t.integer :recipient_id
      t.integer :conversation_id
      t.text :text
      t.boolean :new
      t.boolean :user_deleted
      t.boolean :recipient_deleted

      t.timestamps
    end
  end
end
