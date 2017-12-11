class AddRememberTokenToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :remember_token
    end
  end
end
