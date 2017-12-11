require 'csv'

module Migrators
  module Messages

    class << self

      def import!
        Message.skip_callback :create, :before, :set_new

        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/private_messages.csv', :headers => true) do |row|
          row = row.to_hash
          row.reject! { |k,v| k == 'id' }
          message = Message.new(row)

          conversation = Conversation.with(message.user_id, message.recipient_id, :ids => true)
          conversation = Conversation.new(:user_id => message.user_id, :recipient_id => message.recipient_id) if conversation.blank?
          conversation.last_action_at = message.created_at

          message.save(:validate => false)

          conversation.private_message_id = message.id
          conversation.save(:validate => false)

          message.conversation_id = conversation.id
          message.save
        end
        Message.set_callback :create, :before, :set_new
      end

    end

  end
end