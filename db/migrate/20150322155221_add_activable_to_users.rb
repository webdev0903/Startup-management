class AddActivableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :activable, :boolean, :default => false
  end
end
