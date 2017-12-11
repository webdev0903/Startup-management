# == Schema Information
#
# Table name: conversations
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  recipient_id       :integer
#  last_action_at     :datetime
#  new                :boolean
#  private_message_id :integer
#  user_hide          :boolean
#  recipient_hide     :boolean
#  created_at         :datetime
#  updated_at         :datetime
#

class Conversation < ActiveRecord::Base

  attr_accessible :hidden, :last_action, :private_message_id, :new, :last_action_at,
    :recipient_id, :user_id, :recipient_hide, :user_hide, :messages_attributes

  has_many :messages, :dependent => :destroy
  belongs_to :sender, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :receiver, :class_name => 'User', :foreign_key => 'recipient_id'
  # TODO: has_one instead of belongs_to
  has_one :last_message, -> { order('created_at DESC')}, :class_name => 'Message'

  validates_uniqueness_of :user_id, :scope => [:recipient_id]

  accepts_nested_attributes_for :messages, reject_if: proc { |attributes| attributes['text'].blank? }

  class << self
    def with(user, other_user, opt={})
      # If ids are passed instead of user objects..
      if opt[:ids]
        conditions = {:this_user => user, :other_user => other_user}
      else
        conditions = {:this_user => user.id, :other_user => other_user.id}
      end
      where(
        '(user_id = :this_user and recipient_id = :other_user) OR (recipient_id = :this_user and user_id = :other_user)',
        conditions
      ).first
    end
  end

end
