class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.integer :startup_id
      t.text :text
      t.boolean :for_friends
      t.boolean :for_followers
      t.boolean :for_public
      t.integer :likes_count

      t.timestamps
    end
  end
end
