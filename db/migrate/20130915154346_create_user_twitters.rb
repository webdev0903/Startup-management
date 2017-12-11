class CreateUserTwitters < ActiveRecord::Migration
  def change
    create_table :user_twitters do |t|
      t.integer :user_id
      t.string :name
      t.integer :tweets_count
      t.integer :tweets_per_day
      t.datetime :next_send_at
      t.decimal :uid
      t.boolean :revoked
      t.string :secret
      t.string :oauth_token

      t.timestamps
    end
  end
end
