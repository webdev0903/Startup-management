class AddIndexesToFields < ActiveRecord::Migration

  def change
    add_index :user_parameters, :user_id
    add_index :user_parameters, :country_id
    add_index :user_parameters, :user_role_id
    add_index :user_parameters, :skills, using: 'gin'
    add_index :user_parameters, :markets_interested_in, using: 'gin'

    add_index :users, :url
    add_index :users, :email

    add_index :startups, :url
    add_index :startups, :user_id

    # TODO: Add index to all url columns in every table, esp keywords
  end

end
