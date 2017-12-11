class CreateStartups < ActiveRecord::Migration
  def change
    create_table :startups do |t|
      t.integer :user_id
      t.string :title
      t.string :summary
      t.integer :country_id
      t.string :city
      t.string :url
      t.string :keywords
      t.text :about
      t.string :require
      t.string :website
      t.string :angellist
      t.string :twitter
      t.string :facebook
      t.boolean :status
      t.boolean :english
      t.boolean :homepage
      t.boolean :trending
      t.integer :followers_count
      t.datetime :last_action_at
      t.string :filename
      t.integer :cofounders_count

      t.timestamps
    end
  end
end
