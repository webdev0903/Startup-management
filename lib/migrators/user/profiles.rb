require 'csv'

module Migrators
  module User
    module Profiles

      class << self

          # NOTE: Keywords are to be imported before User Profiles
          # TODO: Handle avatar uploads...
          
        def import!

          ::User::Profile.skip_callback :save, :before, :create_keywords_if_dont_exist
          ::User::Profile.skip_callback :create, :after, :setup_profile

          csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/user_parameters.csv', :headers => true) do |row|
            row = row.to_hash
            stats = Hash.new
            %w[skills markets_interested_in].each { |a| row[a] = row[a].present? ? row[a].split(',') : [] }

            row['skills'] = Keyword.skills.where(:title => row['skills']).map(&:url)
            row['markets_interested_in'] = Keyword.markets.where(:title => row['markets_interested_in']).map(&:url)
            
            %w[followers_count followings_count friends_count].each { |k,v| stats[k] = row[k] }
            row.reject! { |k,v| %w[recommendations recommends score intense startups attend hash followers_count followings_count friends_count next_email].include? k }
            profile = ::User::Profile.new(row)
            profile.save(:validate => false)
            s = ::User::Statistic.where(:user_id => profile.user_id).first
            s.update_attributes(stats) if s.present?
          end

          ::User::Profile.find_by_sql("SELECT setval('user_parameters_id_seq', (SELECT MAX(id) FROM user_parameters))")

          ::User::Profile.set_callback :save, :before, :create_keywords_if_dont_exist
          ::User::Profile.set_callback :create, :after, :setup_profile
        end

      end

    end
  end
end