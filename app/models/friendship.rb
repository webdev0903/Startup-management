# == Schema Information
#
# Table name: friendships
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  friend_id  :integer
#  status     :boolean
#  new        :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Friendship < ActiveRecord::Base

  # NOTE: Use this while importing form lagacy DB
  # attr_accessible :friend_id, :new, :status, :user_id, :created_at

  attr_accessible :friend_id, :new, :status, :user_id

  has_one :notification, :dependent => :destroy

  belongs_to :user
  belongs_to :friend, :class_name => "User"

  # For counter chaces
  belongs_to :statistic, :class_name => 'User::Statistic', :primary_key => 'user_id', :foreign_key => 'user_id'

  validates_uniqueness_of :user_id, :scope => [:friend_id]

  # All firends and firend requests of a user.
  scope :my_relations, lambda { |current_user_id|
    where('user_id = :user_id OR friend_id = :user_id', :user_id => current_user_id)
  }

  before_create :set_new, :inverse_exist
  after_destroy :delete_inverse


  class << self
    def any_contact?(user_one, user_two)
      exists?(['(user_id = :user_one AND friend_id = :user_two) OR
        (user_id = :user_two OR friend_id = :user_one)', :user_one => user_one, :user_two => user_two])
    end
  end

  private
  
    def set_new
      self['status'] = false
      self['new'] = true
    end

    def inverse_exist
      inverse = Friendship.find_by(:friend_id => self.user_id, :user_id => self.friend_id)
      if inverse.present?
        self['new'] = false
        self.status = true
        self['new'] = false
        inverse.status = true
        inverse.save
        profile = User::Statistic.find_or_create_by(:user_id => self.user_id)
        inverse_profile = User::Statistic.find_or_create_by(:user_id => self.friend_id)
        profile.increment(:friends_count).save
        inverse_profile.increment(:friends_count).save
      end
    end

    def delete_inverse
      inverse = Friendship.find_by(:friend_id => self.user_id, :user_id => self.friend_id)      
      if inverse.present?
        profile = User::Statistic.find_or_create_by(:user_id => self.user_id)
        profile.decrement(:friends_count).save
        inverse_profile = User::Statistic.find_or_create_by(:user_id => self.friend_id)        
        inverse_profile.decrement(:friends_count).save
        inverse.destroy              
      end
    end

end
