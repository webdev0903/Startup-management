# == Schema Information
#
# Table name: cronjobs
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  interval     :integer
#  last_at      :datetime
#  next_at      :datetime
#  status       :boolean
#  url          :string(255)
#  quantity     :integer
#  started      :integer
#  ended        :integer
#  ms           :integer
#  created_at   :datetime
#  updated_at   :datetime
#  errors_count :integer
#  answer       :string(255)
#

class Cronjob < ActiveRecord::Base
	attr_accessible :title, :interval, :last_at, :next_at,
	:status, :url, :quantity, :started, :ended, :errors, :ms, :answer

	def self.update_user_statistic (quantity)
		if quantity.present? 
			statistics = User::Statistic.where('updated_at > ? or updated_at is null', (Time.now - (60*60))).order('updated_at ASC').limit(quantity)
			statistics.each do |s|

				# Comments
				s.comments_count = Comment.where(:user_id=>s.user_id).count

				# Posts
				s.posts_count = Post.where(:user_id=>s.user_id).count

				# Conversations
				s.conversations_count = Conversation.where(:user_id=>s.user_id).count

				# Likes
				s.likes_count = Like.where(:user_id=>s.user_id).count

				# Gems
				s.gems_count = Like.where(:recipient_id=>s.user_id).count

				# Friends
				s.friends_count = Friendship.where(:friend_id=>s.user_id, :status=>true).count

				# Followers
				s.followers_count = Follower.where(:recipient_id=>s.user_id, :startup_id=>nil).count

				# Followings
				s.followings_count = Follower.where(:user_id=>s.user_id, :startup_id=>nil).count
				
				s.updated_at = Time.now # because it sometimes doesn't update otherwise

				s.save
			end
			return 'Ok ' + 
			'<br/> Quantity: '+quantity.to_s + 
			'<br/> Updated: '+statistics.count.to_s
		else 
			return 'Error: No Quantity Provided'
		end
	end
end
