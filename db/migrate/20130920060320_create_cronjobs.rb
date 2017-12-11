class CreateCronjobs < ActiveRecord::Migration
  def change
    create_table :cronjobs do |t|
      t.string :title
      t.integer :interval
      t.datetime :last_at
      t.datetime :next_at
      t.boolean :status
      t.string :url
      t.integer :quantity
      t.integer :started
      t.integer :ended
      t.integer :errors
      t.integer :ms

      t.timestamps
    end
  end
end
