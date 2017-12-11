class CreateUserParameters < ActiveRecord::Migration
  def change
    create_table :user_parameters do |t|
      t.integer :user_id
      t.integer :country_id
      t.integer :user_role_id
      t.string :city
      t.string :summary
      t.string :keywords
      t.text :experience
      t.string :current_position
      t.string :interesting_markets
      t.string :looking_for
      t.text :startup_join_conditions
      t.text :startup_conditions
      t.text :startup_add_value
      t.string :startup_locations
      t.string :website
      t.string :angellist
      t.string :twitter
      t.string :linkedin
      t.datetime :last_email_at
      t.datetime :next_email_at
      t.integer :emails_count
      t.integer :referal_id
      t.string :referal_code
      t.boolean :fix
      t.integer :step
      t.boolean :ask_me
      t.boolean :startup_join

      t.timestamps
    end
  end
end
