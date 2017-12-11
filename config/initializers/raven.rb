require 'raven'

Raven.configure do |config|
  config.environments = %w[ production staging ]
  config.tags = { environment: Rails.env }
  config.dsn = 'http://7bd8b0a940944e9fa9490c53f2eadfb0:558d7e32c5684794a1053cd0611daade@sentry.starterpad.com/2'
end