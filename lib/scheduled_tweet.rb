require 'active_support/all'
require 'action_view'
class ScheduledTweet
  include ActionView::Helpers::TextHelper
  attr_reader :user, :log
  TWEET_LENGTH = 140
  def initialize(options={})
    @log =  Logger.new(Rails.root.join('log', 'scheduled_job_twitter.log'))
    @user ||= options[:default_user] || random_user
    @tweet = @user.twitter_tweets.new
    @debug = options[:debug] || false  
    random_tweet if @user
  end

  def random_user
    rand_user = User.active.joins(:twitter_auth, :setting).
      where(status: true).
      where('user_twitters.tweets_per_day > 0').
      where('user_twitters.oauth_token is not NULL').
      where('user_twitters.next_send_at < ? OR user_twitters.next_send_at is NULL',Time.zone.now).
      sample
    @log.info("User: #{rand_user.title}, tweets_per_day: #{rand_user.twitter_auth.tweets_per_day}, next_send_at: #{rand_user.twitter_auth.next_send_at}") rescue  @log.info('No user found.')
    # return rand_user if (UserTwitter.new(rand_user.twitter_auth.oauth_token, rand_user.twitter_auth.secret) rescue false)
    rand_user
  end

  def random_tweet
    if !@user.twitter_auth.tweets_per_day.nil? && @user.twitter_auth.tweets_per_day > 0
      if @user.twitter_auth.next_send_at.nil? || @user.twitter_auth.next_send_at < Time.zone.now
        if [true,false].sample
          random_startup_tweet
          if @user.twitter_service && @tweet.text
            @log.info("#{@user.title} tweeting '#{@tweet.text}'")
            if @debug
              @log.info("DEBUG: tweeted!!")
            else
              if @user.twitter_service.tweet("#{@tweet.text}") # safebuffer to string
                @user.twitter_auth.update_next_send
                @tweet.save
              else
                @log.info("ERROR: Tweeting Failed")
              end
            end          
          end
        else
          random_recipient_tweet
          if @user.twitter_service && @tweet.text
            @log.info("#{@user.title} tweeting '#{@tweet.text}'")
            if @debug
              @log.info("DEBUG: tweeted!!")
            else
              if @user.twitter_service.tweet("#{@tweet.text}") # safebuffer to string
                @user.twitter_auth.update_next_send
                @tweet.save
              else
                @log.info("ERROR: Tweeting Failed")
              end
            end          
          end
        end

      end
    end
    
  end

  def random_startup_not_posted
    startups = @user.twitter_tweets.pluck(:startup_id).compact
    if startups.present?
      startup = Startup.active.joins(:owner).where('users.tweet_opt_in = ?', true).where("startups.id not in (?)", startups).sample
      return startup if startup.present?
    end
    return Startup.active.joins(:owner).where('users.tweet_opt_in = ?', true).offset(rand(1..Startup.active.joins(:owner).where('users.tweet_opt_in = ?', true).count)).limit(1).first
  end

  def random_recipient_not_posted
    users = @user.twitter_tweets.pluck(:recipient_user_id).compact
    return User.active.where(tweet_opt_in: true).where("users.id not in (?)", users).sample if users.present?
    User.active.where(tweet_opt_in: true).offset(rand(0..User.active.where(tweet_opt_in: true).count)).limit(1).first
  end

  def random_startup_tweet
    startup = self.random_startup_not_posted
    # BUG: figure out why startup is nil sometimes
    return nil if startup.nil? 
    @tweet.startup = startup
    title = truncate(startup.title, length: 30, escape: false).gsub(/\s+/, ' ')
    website = startup.web.gsub(/(^http:\/\/www.)|(^http:\/\/)|(^www.)/,'')
    char_left = TWEET_LENGTH - (title.length + 22)
    description = truncate(startup.summary.gsub(/\s+/, ' '), length: (char_left - 10), omission: '..', escape: false)
    description = "#{title}: #{description} starterpad.com/startups/#{startup.url}".gsub(/\s+/, ' ')
    description = description + ' via @StarterPad' if (TWEET_LENGTH - description.length) > 16
    @tweet.text = description.html_safe
  end

  def random_recipient_tweet
    recipient = random_recipient_not_posted
    return nil if recipient.nil?
    @tweet.recipient_user = recipient
    name = truncate(recipient.title.gsub(/\s+/, ' '), length: 30, omission: '..', escape: false)
    description = truncate(recipient.profile.summary.to_s.gsub(/\s+/, ' '), length: 63, omission: '..', escape: false)
    description = "Meet #{name}, #{description} #{recipient.web}"
    description = description + ' via @StarterPad' if description.length > 16    
    @tweet.text = description.html_safe
  end

end
