require 'csv'

module Migrators
  module Startups

    class << self

      # NOTE: Keywords are to be imported before User Profiles
      # TODO: Handle avatar uploads...

      def import!
        Startup.skip_callback :save, :before, :create_keywords_if_dont_exist

        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/startups.csv', :headers => true) do |row|
          row = row.to_hash
          row['markets'] = row['markets'].present? ? row['markets'].split(',') : []
          row['markets'] = Keyword.markets.where(:title => row['markets']).map(&:url)
          
          row.reject! { |k,v| %w[keywords private group_id].include? k }

          startup = Startup.new(row)
          startup.save(:validate => false)
        end

        Startup.find_by_sql("SELECT setval('user_parameters_id_seq', (SELECT MAX(id) FROM user_parameters))")

        Startup.set_callback :save, :before, :create_keywords_if_dont_exist
      end

    end

  end
end