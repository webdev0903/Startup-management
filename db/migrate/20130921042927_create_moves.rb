class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.integer :user_id
      t.integer :conversations
      t.integer :photos
      t.integer :statistics

      t.timestamps
    end
  end
end
