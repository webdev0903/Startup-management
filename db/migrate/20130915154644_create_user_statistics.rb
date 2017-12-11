class CreateUserStatistics < ActiveRecord::Migration
  def change
    create_table :user_statistics do |t|
      t.integer :user_id
      t.integer :comments_count
      t.integer :posts_count
      t.integer :conversations_count
      t.boolean :fix
      t.integer :likes_count

      t.timestamps
    end
  end
end
