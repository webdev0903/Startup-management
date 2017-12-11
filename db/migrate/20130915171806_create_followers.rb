class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.integer :user_id
      t.integer :recipient_id
      t.integer :startup_id

      t.timestamps
    end
  end
end
