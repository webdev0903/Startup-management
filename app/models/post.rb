# == Schema Information
#
# Table name: posts
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  group_id        :integer
#  startup_id      :integer
#  text            :text
#  for_connections :integer          default(0)
#  for_followers   :integer          default(0)
#  for_cofounders  :integer
#  for_users       :integer
#  for_public      :integer          default(0)
#  likes           :integer          default(0), not null
#  created         :datetime         not null
#  old_id          :integer
#

class Post < ActiveRecord::Base

  # NOTE: Use this while importing form lagacy DB
  # attr_accessible :id, :user_id, :group_id, :startup_id, :text, :for_friends, :for_followers,
  # :for_cofounders, :for_users, :for_public, :likes_count, :created_at
  
  attr_accessible :for_followers, :for_friends, :for_public, 
  :gems, :startup_id, :text, :user_id, :visibility, :group_id, :user

  attr_accessor :visibility

  paginates_per 10

  # relations
  has_many :comments, :order => 'created_at ASC', :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :notifications, :dependent => :destroy

  belongs_to :user
  belongs_to :startup
  belongs_to :group
  # NOTE: Coment this line when importing lagacy DB
  belongs_to :statistic, :class_name => 'User::Statistic', :primary_key => 'user_id', :foreign_key => 'user_id', :counter_cache => true

  VISIBILITY = {"Everyone" => 'everyone', "Friends" => 'friends', "Friends and Followers" => 'followers'}

  # validations
  validates :text, :presence => {:message => "Post can't be blank." }
  validates :visibility, :inclusion => { :in => VISIBILITY.values }, :allow_blank => true 
  validate :status_of_user_must_active

  # callback
  before_create :set_visibility, :set_likes_count

  class << self
    def with_my_like(user_id)
      where(:user_id => user_id)
    end
  end

  def set_visibility
    if visibility == 'everyone'
      self.for_public = true
      self.for_followers = true
    elsif visibility == 'followers'
      self.for_followers = true
    end
    self.for_friends = true
  end

  def set_likes_count
    self.likes_count = 0
  end

  private

    def status_of_user_must_active
      errors.add(:user, I18n.t('.errors.messages.user_is_not_active')) if user && !user.status?
    end

end
