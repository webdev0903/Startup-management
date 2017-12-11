require 'csv'

module Migrators
  module Users

    class << self

      def import!
        User.skip_callback :create, :after, :create_profile, :create_statistic, :create_setting, :setup_profile

        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/users.csv', :headers => true) do |row|
          row = row.to_hash
          row.reject! { |k,v| %w[admin remind].include? k }
          user = User.new(row)
          user.save(:validate => false)
        end
        User.find_by_sql("SELECT setval('users_id_seq', (SELECT MAX(id) FROM users))")

        User.set_callback :create, :after, :create_profile, :create_statistic, :create_setting, :setup_profile
      end

    end

  end
end