class UpdateUrlSlugToCountry < ActiveRecord::Migration
  def change
    Country.all.each do |c|
      c.update_attribute :url_slug, c.title.to_url
    end
  end
end
