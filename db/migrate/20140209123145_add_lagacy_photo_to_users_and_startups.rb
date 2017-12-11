class AddLagacyPhotoToUsersAndStartups < ActiveRecord::Migration
  def change
    add_column :users, :lagacy_photo, :string
    add_column :startups, :lagacy_photo, :string
  end
end
