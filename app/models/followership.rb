# == Schema Information
#
# Table name: followers
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  recipient_id :integer
#  startup_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Followership < ActiveRecord::Base

  self.table_name = 'followers'

  # NOTE: Use this while importing form lagacy DB
  # attr_accessible :user_id, :recipient_id, :created_at, :startup_id
  attr_accessible :startup_id, :user_id, :following, :follower, :user_id, :recipient_id, :startup_id

  # validates_uniqueness_of :startup_id, scope: :user_id

  #has_one :notification, :dependent => :destroy
  has_one :notification, :dependent => :destroy, :foreign_key => 'follower_id'

  # Belongs to follower in human terms
  belongs_to :following, :class_name => 'User', :foreign_key => 'user_id'
  # Belongs to followed in human terms
  belongs_to :followed, :class_name => 'User', :foreign_key => 'recipient_id'
  belongs_to :startup
  # For Counter Cache, Comment these while importing from lagacy DB
  belongs_to :following_statistic, :class_name => 'User::Statistic', :primary_key => 'user_id', :foreign_key => 'user_id', :counter_cache => :followings_count
  belongs_to :follower_statistic, :class_name => 'User::Statistic', :primary_key => 'user_id', :foreign_key => 'recipient_id', :counter_cache => :followers_count

  validates_uniqueness_of :user_id, :scope => [:recipient_id, :startup_id]
  # validate :status_of_user_must_active

  private
    def status_of_user_must_active
      errors.add(:following, I18n.t('.errors.messages.user_is_not_active')) if following && !following.status?
      errors.add(:follower, I18n.t('.errors.messages.user_is_not_active')) if  followed && !followed.status?
    end

end
