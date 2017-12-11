class AddCountryUrlSlugToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :url_slug, :string
  end
end
