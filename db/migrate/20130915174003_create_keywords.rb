class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.integer :parent_id
      t.string :title
      t.string :url
      t.boolean :skill
      t.boolean :market
      t.integer :users_count
      t.integer :startups_count
      t.integer :followers_count
      t.boolean :status
      t.datetime :synced_at

      t.timestamps
    end
  end
end
