class AddLastEmailAtToStartups < ActiveRecord::Migration
  def change
  	add_column :startups, :last_email_at, :datetime
  end
end
