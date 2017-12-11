# == Schema Information
#
# Table name: twitter_tweets
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  group_id          :integer
#  startup_id        :integer
#  recipient_user_id :integer
#  text              :string(280)
#

class TwitterTweet < ActiveRecord::Base
  belongs_to :group
  belongs_to :recipient_user, class_name: 'User'
  belongs_to :startup
  belongs_to :user

  validates :text, length: { in: 6..140 }
  validates :user_id, presence: true

end
