# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  group_id   :integer
#  status     :boolean
#  suggested  :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Membership < ActiveRecord::Base

  # Use this while importing form lagacy DB
  # attr_accessible :user_id, :group_id, :status, :created_at, :suggested
  attr_accessible :user

  belongs_to :user
  belongs_to :group

  validates_uniqueness_of :user_id, :scope => [:group_id]
  # validate :status_of_user_must_active
  def status_of_user_must_active
    errors.add(:user, I18n.t('.errors.messages.user_is_not_active')) if user && !user.status?
  end
end
