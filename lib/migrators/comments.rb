require 'csv'

module Migrators
  module Comments

    class << self

      BATCH_SIZE = 100
    
      def import!
        comments = []
        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/comments.csv', :headers => true) do |row|
          row = row.to_hash
          row.reject!{ |k,v| %w[id group_id startup_id group_post_id].include? k }
          comments << Comment.new(row)
          if comments.size > BATCH_SIZE
            Comment.import comments, :validate => false
            comments = []
          end
        end
        Comment.import comments, :validate => false
      end

    end

  end
end