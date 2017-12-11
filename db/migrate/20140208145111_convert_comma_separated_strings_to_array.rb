class ConvertCommaSeparatedStringsToArray < ActiveRecord::Migration

  def change
    add_column :user_parameters, :skills, :string, array: true, null: false, default: []
    add_column :user_parameters, :markets_interested_in, :string, array: true, null: false, default: []
    add_column :startups, :markets, :string, array: true, null: false, default: []

    User::Profile.all.each do |profile|
      skills = Keyword.skills.where(:title => profile.keywords.present? ? profile.keywords.split(',') : []).pluck(:url)
      markets = Keyword.markets.where(:title => profile.interesting_markets.present? ? profile.interesting_markets.split(',') : []).pluck(:url)
      profile.skills = skills
      profile.markets_interested_in = markets
      profile.save
    end

    Startup.all.each do |startup|
      markets = Keyword.markets.where(:title => startup.keywords.present? ? startup.keywords.split(',') : []).pluck(:url)
      startup.markets = markets
      startup.save
    end


    remove_column :user_parameters, :keywords
    remove_column :user_parameters, :interesting_markets
    remove_column :startups, :keywords

  end

end
