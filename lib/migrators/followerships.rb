require 'csv'

module Migrators
  module Followerships

    class << self

      BATCH_SIZE = 1000
    
      def import!
        followerships = []
        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/user_followings.csv', :headers => true) do |row|
          row = row.to_hash
          row.delete 'id'
          followerships << Followership.new(row)
          if followerships.size > BATCH_SIZE
            Followership.import followerships, :validate => false
            followerships = []
          end
        end
        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/startup_followers.csv', :headers => true) do |row|
          row = row.to_hash
          row.delete 'id'
          followerships << Followership.new(row)
          if followerships.size > BATCH_SIZE
            Followership.import followerships, :validate => false
            followerships = []
          end
        end
        Followership.import followerships, :validate => false
      end

    end

  end
end