class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :title
      t.string :url
      t.string :old_password
      t.datetime :last_action_at
      t.boolean :status
      t.boolean :admin
      t.string :filename
      t.string :timezone

      t.timestamps
    end
  end
end
