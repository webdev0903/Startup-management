class CreateStartupStatistics < ActiveRecord::Migration
  def change
    create_table :startup_statistics do |t|
      t.integer :startup_id
      t.integer :followers_count

      t.timestamps
    end
  end
end
