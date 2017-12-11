require 'csv'

module Migrators
  module User
    module Statistics

      class << self

        def import!

          csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/user_statistics.csv', :headers => true) do |row|
            row = row.to_hash
            row.reject! { |k,v| %w[badge_syncs_sync likes_sync].include? k }
            s = ::User::Statistic.new(row)
            s.save(:validate => false)
          end
          
          ::User::Statistic.find_by_sql("SELECT setval('user_statistics_id_seq', (SELECT MAX(id) FROM user_statistics))")

        end

      end

    end
  end
end