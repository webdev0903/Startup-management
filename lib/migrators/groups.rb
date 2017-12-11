require 'csv'

module Migrators
  module Groups

    # TODO: Handle avatar uploads...

    class << self
    
      def import!
        Post.skip_callback :create, :before, :set_last_action_at
        Post.skip_callback :create, :after, :create_memberhip_of_owner

        CSV.foreach(Rails.root.to_s + '/db/lagacy/groups.csv', :headers => true) do |row|
          group = Group.new(row.to_hash)
          group.save(:validate => false)
        end
        # Update last_action_at to created_at
        Group.where('last_action_at IS NULL').update_all('last_action_at = created_at')
        Group.find_by_sql("SELECT setval('groups_id_seq', (SELECT MAX(id) FROM groups))")

        Post.set_callback :create, :before, :set_last_action_at
        Post.set_callback :create, :after, :create_memberhip_of_owner
      end

    end

  end
end