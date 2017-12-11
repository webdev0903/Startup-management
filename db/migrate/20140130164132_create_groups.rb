class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.belongs_to    :user
      t.string        :title
      t.attachment    :photo
      t.string        :lagacy_photo
      t.string        :url #Just for consistency naming it :url, Otherwise :slug is much better
      t.string        :about
      t.text          :long_about
      t.integer       :privacy
      t.boolean       :status
      t.boolean       :homepage
      t.boolean       :trending
      t.datetime      :last_action_at
      t.integer       :members_count
      t.timestamps
    end
  end
end
