class CreateCofounders < ActiveRecord::Migration
  def change
    create_table :cofounders do |t|
      t.string :user_id
      t.string :startup_id

      t.timestamps
    end
  end
end
