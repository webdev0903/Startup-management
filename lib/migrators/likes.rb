require 'csv'

module Migrators
  module Likes

    class << self

      BATCH_SIZE = 500
    
      def import!
        likes = []
        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/likes.csv', :headers => true) do |row|
          row = row.to_hash
          row.reject!{ |k,v| %w[id group_id group_post_id].include? k }
          likes << Like.new(row)
          if likes.size > BATCH_SIZE
            Like.import likes, :validate => false
            likes = []
          end
        end
        Like.import likes, :validate => false
      end

    end

  end
end