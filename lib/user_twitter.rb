class UserTwitter
  
  def initialize(oauth_token, secret_token)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = TWITTER_CONSUMER_KEY
      config.consumer_secret     = TWITTER_ACCESS_TOKEN
      config.access_token        = oauth_token
      config.access_token_secret = secret_token
    end
    @log =  Logger.new(Rails.root.join('log', 'scheduled_job_twitter.log'))
    @client.verify_credentials    
  end

  def tweet(status)
    success = true
    @client.update(status)
    return true
  rescue => e    
    @log.debug "ERROR: #{e.inspect}"
    return false
  end

end