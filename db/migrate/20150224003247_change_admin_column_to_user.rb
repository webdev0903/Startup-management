class ChangeAdminColumnToUser < ActiveRecord::Migration
  def up
  	execute 'ALTER TABLE users ALTER COLUMN admin  DROP DEFAULT'
  	change_column :users, :admin, "boolean USING CAST(admin AS boolean)",  default: false
  end
  def down
  end
end