# == Schema Information
#
# Table name: comments
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  text          :text
#  post_id       :integer
#  group_id      :integer
#  startup_id    :integer
#  group_post_id :integer
#  likes         :integer          default(0)
#  created       :datetime
#

class Comment < ActiveRecord::Base

  # NOTE: Use this while importing form lagacy DB
  # attr_accessible :user_id, :post_id, :text, :likes_count, :created_at

  attr_accessible :post_id, :text
  validates :text, :presence => {:message => "Comment can't be blank." }
  belongs_to :user
  belongs_to :post
  belongs_to :statistic, :class_name => 'User::Statistic', :primary_key => 'user_id', :foreign_key => 'user_id', :counter_cache => true
  has_many :notifications, :dependent => :destroy

  def owner?(user)
    post.user == user || self.user == user
  end
end
