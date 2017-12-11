class ChangeWebsiteColumnToUserParameters < ActiveRecord::Migration
  def up
    #alter table "containers" alter "products" drop default;
    #alter table "containers" alter "products" type text[] using array[products];
    #alter table "containers" alter "products" set default '{}';
    execute 'ALTER TABLE user_parameters ALTER COLUMN website  DROP DEFAULT'
    change_column :user_parameters, :website, "varchar(255)[] USING ARRAY[website]",  default: '{}'
  end
  def down
    execute 'ALTER TABLE user_parameters ALTER COLUMN website  DROP DEFAULT'
    change_column :user_parameters, :website, "varchar(255) USING(array_to_string(website,''))"
  end
end
