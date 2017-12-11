require 'csv'

module Migrators
  module Posts

    class << self

      def import!
        Post.skip_callback :create, :before, :set_visibility, :set_likes_count
        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/posts.csv', :headers => true) do |row|
          row = row.to_hash
          row.reject! { |k,v| %w[old_id for_users].include? k }
          post = Post.new(row.to_hash)
          post.save(:validate => false)
        end
        Post.where('group_id = 0').update_all('group_id = NULL')
        Post.find_by_sql("SELECT setval('posts_id_seq', (SELECT MAX(id) FROM posts))")
        Post.set_callback :create, :before, :set_visibility, :set_likes_count
      end

    end

  end
end