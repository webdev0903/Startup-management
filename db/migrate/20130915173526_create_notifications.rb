class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :recipient_id
      t.string :key_name
      t.integer :post_id
      t.integer :comment_id
      t.integer :like_id
      t.integer :startup_id
      t.integer :friendship_id
      t.integer :follower_id
      t.boolean :read

      t.timestamps
    end
  end
end
