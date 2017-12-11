# == Schema Information
#
# Table name: notifications
#
#  id                     :integer          not null, primary key
#  recipient_id           :integer          not null
#  type                   :string(60)       not null
#  post_id                :integer
#  comment_id             :integer
#  like_id                :integer
#  group_id               :integer
#  group_user_id          :integer
#  group_post_id          :integer
#  startup_id             :integer
#  question_id            :integer
#  question_answer_id     :integer
#  question_vote_id       :integer
#  question_follower_id   :integer
#  user_id                :integer
#  user_connection_id     :integer
#  user_following_id      :integer
#  user_recommendation_id :integer
#  startup_follower_id    :integer
#  read                   :integer          default(0), not null
#  created                :datetime         not null
#  is_emailed             :integer          default(0), not null
#

class Notification < ActiveRecord::Base

  # NOTE: Use this while importing form lagacy DB
  # attr_accessible :recipient_id, :key_name, :post_id, :comment_id, :like_id, :group_id, :startup_id, 
  # :user_id, :friendship_id, :follower_id, :read, :created_at

  attr_accessible :comment_id, :like_id, :post_id, :read, :recipient_id, :startup_id,
  :key_name, :user_id, :friendship_id, :follower_id, :group_id

  belongs_to :user
  belongs_to :post
  belongs_to :group
  belongs_to :startup
  belongs_to :follower, class_name: 'User', foreign_key: 'user_id'
  belongs_to :recipient, :class_name => "User", :foreign_key => "recipient_id"

  validates :key_name, :inclusion => { :in => %w[group_suggest group_join group_add after_friend_request startup_post user_follow
    follows_back post_like group_post post_comment friend_request friend_accept startup_follow suggest_group] }

  scope :unread, -> { where(read: false) }

  after_initialize :mark_new
  
  class << self

    def generate_for_post(post_id, commenter_id, comment_id)
      to_be_notified = Post.where(id: post_id).pluck(:user_id) +
        Like.where(post_id: post_id).pluck(:user_id) + Comment.where(post_id: post_id).pluck(:user_id) + []

      # exclude myself
      to_be_notified.uniq!
      to_be_notified.delete(commenter_id)

      # create notifications
      to_be_notified.each do |user_id| 
        n = create({
          user_id: commenter_id, 
          recipient_id: user_id,
          post_id: post_id,
          comment_id: comment_id, 
          key_name: 'post_comment'
        })
      end
      
    end

    def generate_for_startup_post(post_id, commenter_id, startup_id)
      startup_var = Startup.where(url: startup_id).first
      to_be_notified = Startup.where(id: startup_var.id).first.followers.pluck(:id) #Post.where(id: post_id).pluck(:user_id) + []
      
      # exclude myself
      to_be_notified.uniq!
      to_be_notified.delete(commenter_id)
      
      # create notifications
      to_be_notified.each do |user_id| 
        n = create({
          user_id: commenter_id, 
          startup_id: startup_var.id,
          recipient_id: user_id,
          post_id: post_id,
          #comment_id: comment_id, 
          key_name: 'startup_post'
        })
      end
    end

    def generate_for_startup_follow(commenter_id, startup_id)
      startup_var = Startup.where(url: startup_id).first
      to_be_notified = Startup.where(id: startup_var.id).first 
      
      # create notifications
      n = create({
        user_id: commenter_id, 
        startup_id: startup_var.id,
        recipient_id: to_be_notified.user_id,
        #comment_id: comment_id, 
        key_name: 'startup_follow'
      })
    end

    def generate_for_group_post(post_id, commenter_id, group_id)
      group_var = Group.where(url: group_id).first
      to_be_notified = Group.where(id: group_var.id).first.memberships.pluck(:user_id)
      
      # exclude myself
      to_be_notified.uniq!
      to_be_notified.delete(commenter_id)
      
      # create notifications
      to_be_notified.each do |user_id| 
        n = create({
          user_id: commenter_id, 
          group_id: group_var.id,
          recipient_id: user_id,
          post_id: post_id,
          key_name: 'group_post'
        })
      end
    end

    def generate_for_group_join(commenter_id, group_id)
      group_var = Group.where(id: group_id).first
      to_be_notified = Group.where(id: group_var.id).first 
      
      # create notifications
      n = create({
        user_id: commenter_id, 
        group_id: group_id,
        recipient_id: to_be_notified.user_id,
        key_name: 'group_join'
      })
    end

    def generate_for_post_like(commenter_id, post_id)
      to_be_notified = Post.where(id: post_id).first 
      
      # create notifications
      n = create({
        user_id: commenter_id, 
        post_id: post_id,
        recipient_id: to_be_notified.user_id,
        key_name: 'post_like'
      })
    end

    def generate_for_group_suggest(suggester_id, recipient_id, group_id)
      check_n = Notification.where('group_id = ? AND recipient_id = ?', group_id, recipient_id)
      # create notifications
      if check_n.present?
      else
        n = create({
          user_id: suggester_id, 
          group_id: group_id,
          recipient_id: recipient_id,
          key_name: 'suggest_group'
        })
      end
    end

  end

  private

    def mark_new
      self.read = false
    end


end
