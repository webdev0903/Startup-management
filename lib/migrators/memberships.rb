require 'csv'

module Migrators
  module Memberships

    class << self

      BATCH_SIZE = 1000
    
      def import!
        memberships = []
        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/group_users.csv', :headers => true) do |row|
          row = row.to_hash
          row.delete('id')
          memberships << Membership.new(row)
          if memberships.size > BATCH_SIZE
            Membership.import memberships, :validate => false
            memberships = []
          end
        end
        Membership.import memberships, :validate => false
      end

    end

  end
end