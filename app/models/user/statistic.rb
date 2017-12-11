# == Schema Information
#
# Table name: user_statistics
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  comments         :integer
#  posts            :integer
#  conversations    :integer
#  likes            :integer
#  badge_syncs_sync :datetime
#  likes_sync       :datetime
#

class User::Statistic < ActiveRecord::Base

  # NOTE: Use this while importing form lagacy DB
	# attr_accessible :id, :comments_count, :posts_count, :likes_count, :friends_count,
	# :conversations_count, :followers_count, :followings_count, :users_count, :user_id

  belongs_to :user
  has_many :likes, :foreign_key => 'recipient_id'
  has_many :posts, :foreign_key => 'user_id'
  has_many :comments, :foreign_key => 'user_id'
  has_many :friendships, :foreign_key => 'user_id'
  has_many :followerships, :class_name => 'Followership', :foreign_key => 'recipient_id'
  has_many :followingships, :class_name => 'Followership', :foreign_key => 'user_id'


  # TODO: add groups_count counter cache as well
  
end
