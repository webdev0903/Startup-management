class CreateUserFacebooks < ActiveRecord::Migration
  def change
    create_table :user_facebooks do |t|
      t.integer :user_id
      t.string :name
      t.decimal :uid
      t.string :oauth_token
      t.datetime :oauth_expires_at
      t.string :email

      t.timestamps
    end
  end
end
