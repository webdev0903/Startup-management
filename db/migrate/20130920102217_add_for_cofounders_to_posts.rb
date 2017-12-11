class AddForCofoundersToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :for_cofounders, :boolean
  end
end
