Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, Settings.twitter.key, Settings.twitter.secret,
  {    
    :image_size => 'original',
  }
  provider :facebook, Settings.facebook.id, Settings.facebook.secret, scope: "email", secure_image_url: true, image_size: 'large'
end