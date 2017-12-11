class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.string :title
      t.string :url
      t.integer :users_count

      t.timestamps
    end
  end
end
