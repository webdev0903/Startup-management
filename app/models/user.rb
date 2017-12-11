# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  email       :string(500)
#  title       :string(500)
#  slug        :string(500)
#  password    :string(500)
#  last_action :datetime
#  remind      :string(500)
#  status      :integer          default(0)
#  admin       :integer          default(0)
#  homepage    :integer          default(0)
#  filename    :string(500)
#  time_zone   :string(300)
#

class User < ActiveRecord::Base
  include Photoable
  include Humanizer
  include PgSearch

  # NOTE: Use this while importing form lagacy DB
  # attr_accessible :id, :email, :title, :url, :old_password, :last_action_at,
  # :status, :homepage, :lagacy_photo, :timezone
  attr_accessor :bypass_humanizer
  # Fields
  attr_accessible :photo, :admin, :email, :title, :password, :password_confirmation, :remember_me, 
    :last_action_at, :profile_attributes, :setting_attributes, :status, :humanizer_answer,
    :humanizer_question_id, :twitter_id, :bypass_humanizer, :follower, :homepage, :activable, :tweet_opt_in, :timezone

  # Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable

  # NOTE: Coment this line when importing lagacy DB
  acts_as_url :title, :limit => 50, :sync_url => true

  # All these Relations, thanks to the guy who designed this Effin Schema.. :(
  has_one :profile, :class_name => 'User::Profile', :dependent => :destroy
  has_one :setting, :class_name => 'User::Setting', :dependent => :destroy
  has_one :twitter_auth, :class_name => 'User::TwitterAuth', :dependent => :destroy
  has_one :facebook_auth, :class_name => 'User::FacebookAuth', :dependent => :destroy
  has_one :statistic, :class_name => 'User::Statistic', :dependent => :destroy

  has_many :initiated_conversations, :class_name => 'Conversation', :foreign_key => 'user_id'
  has_many :involved_conversations, :class_name => 'Conversation', :foreign_key => 'recipient_id'

  has_many :sent_messages, :class_name => 'Message', :dependent => :destroy
  has_many :received_messages, :foreign_key => 'recipient_id', :class_name => 'Message', :dependent => :destroy
  has_many :likes
  has_many :posts, :dependent => :destroy
  has_many :comments, :dependent => :destroy

  has_many :friend_requests, -> { where "friendships.status = 'f'" }, :class_name => "Friendship", :foreign_key => "friend_id", :dependent => :destroy
  has_many :sent_friend_requests, -> { where "friendships.status = 'f'" }, :class_name => "Friendship", :foreign_key => "user_id", :dependent => :destroy
  
  # Circular Association, User has many friends as well as inverse friends
  has_many :friendships, -> { where("friendships.status = 't'").uniq }
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, -> { where("friendships.status = 't'").uniq }, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user

  # Circular Association, User has many followers as well as followings
  has_many :followerships, :class_name => 'Followership', :foreign_key => 'recipient_id'
  has_many :followers, -> { where("status = 't'").uniq }, :through => :followerships, :source => :following
  has_many :followingships, :class_name => 'Followership', :foreign_key => 'user_id'
  has_many :followings, -> { where("status = 't'").uniq }, :through => :followingships, :source => :followed


  has_many :startup_followingships, :class_name => 'Followership', :foreign_key => 'user_id'
  has_many :startup_followings, :through => :startup_followingships, :source => :startup

  has_many :owned_startups, :class_name => 'Startup'
  has_many :owned_groups, :class_name => 'Group'

  has_many :cofounderships, :dependent => :destroy
  has_many :startups, :through => :cofounderships

  has_many :memberships
  has_many :groups, :through => :memberships 

  has_many :notifications, :foreign_key => 'recipient_id', :dependent => :destroy

  has_many :twitter_tweets, dependent: :destroy
  has_many :mentions, foreign_key: :recipient_user_id, class_name: 'TwitterTweets'

  has_many :items, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :item_comments, dependent: :destroy
  
  has_attached_file :photo, 
    :path => ':rails_root/public/uploads/:class/:attachment/:id/:style/:filename',
    :url => '/uploads/:class/:attachment/:id/:style/:filename',
    :styles => { 
      :small => {
        :geometry => "40x40#",
        :quality => "93"
      }, 
      :thumb => {
        :geometry => "120x120#",
        :quality => "93"
      }, 
      :middle => {
        :geometry => "300x300>",
        :quality => "93"
      }, 
      :big => {
        :geometry => "500x500>",
        :quality => "93"
      }, 
      :large => {
        :geometry => "800x800>",
        :quality => "93"
      } 
    }, 
    :default_url => '/images/user_:style.png'
  accepts_nested_attributes_for :profile, :setting

  LAGACY_SALT = 'GFSAehddf1212f1*re_-dsdfassdafGHIkoptD%dsfJ'

  # Validation
  validates :title, presence: true
  validates :email, :uniqueness => true, :allow_nil => true, :allow_blank => true
  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => /^image\/(jpg|jpeg|pjpeg|png|x-png|gif)$/, :message => 'file type is not allowed (only jpeg/png/gif images)'

  # Humanizer validation
  require_human_on :create, :unless => :bypass_humanizer

  scope :active, -> { where(status: true) }
  scope :inactive, -> { where("status != 't'") }
  scope :activable, -> { where("status != 't' and activable = 't'") }
  scope :with_morning_mail, -> { active.joins(:setting).where(email_settings: 
                                { morning_mail: true }) }
  scope :is_complete, ->{
    inactive.joins(:profile).where("(email IS NOT NULL AND title IS NOT NULL AND city IS NOT NULL AND timezone is not NULL AND
        summary IS NOT NULL AND current_position IS NOT NULL AND looking_for IS NOT NULL AND experience IS NOT NULL AND
        country_id IS NOT NULL AND user_role_id IS NOT NULL)
        AND (photo_file_name IS NOT NULL OR lagacy_photo IS NOT NULL)
        AND skills != '{}' AND markets_interested_in != '{}'")
  }

  #search scope
  pg_search_scope :search_by_city, :associated_against => {
    :profile => :city
  }

  after_create :create_profile, :create_statistic, :create_setting
  before_save :update_activable

  class << self

    def from_omniauth(auth)
      where(auth.slice("provider", "uid")).first || create_from_omniauth(auth)
    end

    def create_from_omniauth(auth)
      create! do |user|
        user.provider = auth["provider"]
        user.uid = auth["uid"]
        user.name = auth["info"]["nickname"]
      end
    end

    def email_already_used?(email)
      return true if where(email: email).present? || where(unconfirmed_email: email).present?
      false
    end

    def ready_for_morning_mail
      hour = Time.now.in_time_zone('UTC').hour
      morning_zone = []
      WaktuSubuh.new.morning_zone(hour).each do |tz|
        morning_zone = morning_zone + WaktuSubuh.build_time_zone_list(:all, tz)
      end
      with_morning_mail.where('(email_settings.next_email_at < ? OR email_settings.next_email_at IS NULL)', Time.zone.now).
                        where('timezone ~* ?', morning_zone.uniq.join('|')) # => Postgres Specific Feature ~*      
    end    
  end
  def update_activable
    if email.present? && title.present? && profile.present? && profile.city.present? && timezone.present? && profile.summary.present? && profile.current_position.present? &&
      profile.looking_for.present? && profile.experience.present? && profile.country_id.present? && profile.user_role_id.present? &&
      ( photo_file_name.present? || lagacy_photo.present? ) && profile.skills.present? & profile.markets_interested_in.present?

      self.activable = true
    else
      self.activable = false
    end
    true
  end
  def valid_password?(password)
    return false if encrypted_password.blank?
    Devise.secure_compare(Digest::SHA1.hexdigest(self.password_salt+password), self.encrypted_password)
  end
  # Override devise method to allow lagacy users to login..
  def valid_password?(password)
    if encrypted_password.present?
      super
    else
     
      old_password == Digest::SHA1.hexdigest(LAGACY_SALT + password)
    end
  end

  def my_pad_posts
    friends_ids = friends.active.pluck(:friend_id)
    followings_ids = followings.active.pluck(:recipient_id)
    conditions =
      "((posts.user_id IN (?) AND posts.for_friends = 't') OR
        (posts.user_id IN (?) AND posts.for_followers = 't') OR
        posts.for_public = 't' OR user_id = ?)"
    Post.includes(:user, :likes, :comments => [:user]).where(conditions, friends_ids, followings_ids, id).order('id DESC')
  end

  def my_suggested_starters
    users_to_skip = friends.active.pluck(:id).flatten + followings.pluck(:recipient_id) + [id]
    if self.profile.blank? || self.profile.country_id.blank?
      @users = User.active.where("id NOT IN (?)", users_to_skip.uniq).includes(:profile).limit(5)
    else
      @users = User.active.where("user_id NOT IN (?)", users_to_skip.uniq).joins(:profile).includes([{:profile => :country}]).where('user_parameters.country_id = ?', self.profile.country_id).limit(5)
    end
    #User.active.where("id NOT IN (?)", users_to_skip.uniq).includes(:profile).limit(5)
    #@users = @users.sort_by { |p| [p.followers.size, p.friends.size] }
  end

  def my_suggested_groups
    # Zero for JIC user hasn't joined any group..
    # groups_to_skip = groups.active.pluck(:id) + [0]
    # Group.active.where("id NOT IN (?)", groups_to_skip.uniq).limit(5)
    # Code above is old code for load suggested group.
    groups_not_include = self.groups.pluck(:id)
    Group.where(homepage: true).where("id NOT IN (?)", groups_not_include).limit(5)
  end

  def conversation_with(user)
    Conversation.with(self, user)
  end

  def item_votes
    votes.where(votable_type: "Item")
  end

  def username
    status? ? read_attribute(:url): "[deleted]"
  end

  def to_param
    url
  end

  def online?
    return false if self.last_action_at == nil
    Time.now - self.last_action_at < 5.minutes
  end

  def is_following?(user_id)
    return true if followings.pluck(:id).include?(user_id)
    false
  end

  # Return today's auto tweeted
  def todays_auto_tweet_count
    self.twitter_tweets.count
  end

  def web
    Rails.application.routes.url_helpers.profile_url(self)
  end

  # Return UserTwitter Instance
  def twitter_service    
    begin
      @user_twitter ||= UserTwitter.new(twitter_auth.oauth_token, twitter_auth.secret)
    rescue
      # twitter_auth.destroy
      @user_twitter = nil
    end
    # User credentials is invalid, we force it to disable autopost
    # @TODO safely Remove these 3 line
    # if @user_twitter.blank? && profile
    #   profile.disable_autotweet
    # end
    @user_twitter
  end

  def follow_startup(startup)
    result = startup_followings << startup rescue false
    result
  end

  def unfollow_startup(startup)
    startup_followingships.where(startup: startup).delete_all
  end

  def is_following_startup?(startup)
    startup_followings.pluck(:id).include? startup.id
  end

end
