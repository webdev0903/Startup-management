# == Schema Information
#
# Table name: likes
#
#  id            :integer          not null, primary key
#  post_id       :integer
#  user_id       :integer
#  recipient_id  :integer
#  comment_id    :integer
#  group_id      :integer
#  group_post_id :integer
#

class Like < ActiveRecord::Base

  # NOTE: Use this while importing form lagacy DB
  # attr_accessible :comment_id, :post_id, :recipient_id, :user_id

  attr_accessible :comment_id, :post_id, :recipient_id, :user_id

  has_many :notifications, :dependent => :destroy
  belongs_to :user
  belongs_to :receiver, :class_name => 'User', :foreign_type => 'recipient_id'
  belongs_to :comment
  belongs_to :post, :counter_cache => true

  # NOTE: Comment this line while importing form lagacy DB
  belongs_to :statistic, :class_name => 'User::Statistic', :primary_key => 'user_id', :foreign_key => 'recipient_id', :counter_cache => true

  validates_uniqueness_of :user_id, :scope => [:post_id]

end
