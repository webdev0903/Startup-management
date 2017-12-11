class CreateTwitterTweets < ActiveRecord::Migration
  def change
    create_table :twitter_tweets do |t|
      t.references :group, index: true
      t.belongs_to :recipient_user, index: true
      t.references :startup, index: true
      t.string :text
      t.references :user, index: true

      t.timestamps
    end
  end
end
