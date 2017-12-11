# == Schema Information
#
# Table name: private_messages
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  recipient_id      :integer
#  text              :text
#  new               :integer          default(1)
#  user_deleted      :integer          default(0)
#  recipient_deleted :integer          default(0)
#  created           :datetime
#

class Message < ActiveRecord::Base

  self.table_name = 'private_messages'

  # NOTE: Use this while importing form lagacy DB
  attr_accessible :user_id, :recipient_id, :text, :new, :user_deleted, :recipient_deleted, :created_at

  # attr_accessible :new, :recipient_deleted, :recipient_id, :text,
  #   :user_deleted, :user_id

  belongs_to :conversation, :class_name => 'Conversation', :touch => true # update conversation's updated_at field
  belongs_to :sender, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :receiver, :class_name => 'User', :foreign_key => 'recipient_id'

  before_create :set_new

  validate :status_of_user_must_active

  private

    def set_new
      self['new'] = true
    end

    def status_of_user_must_active
      errors.add(:sender, I18n.t('.errors.messages.user_is_not_active')) if sender && !sender.status?
      errors.add(:receiver, I18n.t('.errors.messages.user_is_not_active')) if  receiver && !receiver.status?
    end

end
