require 'csv'

module Migrators
  module Friendships

    class << self

      BATCH_SIZE = 1000
    
      def import!
        friendships = []
        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/user_connections.csv', :headers => true) do |row|
          row = row.to_hash
          row.reject!{ |k,v| k == 'id' }
          friendships << Friendship.new(row)
          if friendships.size > BATCH_SIZE
            Friendship.import friendships, :validate => false
            friendships = []
          end
        end
        Friendship.import friendships, :validate => false
      end

    end

  end
end