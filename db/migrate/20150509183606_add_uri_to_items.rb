class AddUriToItems < ActiveRecord::Migration
  def change
  	add_column :items, :uri, :string
  end
end
