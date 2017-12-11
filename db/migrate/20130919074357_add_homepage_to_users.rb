class AddHomepageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :homepage, :boolean
  end
end
