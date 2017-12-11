class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :post_id
      t.integer :startup_id
      t.text :text
      t.integer :likes_count

      t.timestamps
    end
  end
end
