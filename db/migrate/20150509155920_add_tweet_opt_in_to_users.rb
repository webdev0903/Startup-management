class AddTweetOptInToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :tweet_opt_in, :boolean, :default => true
  end
end
