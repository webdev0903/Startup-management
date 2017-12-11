# encoding: utf-8
class SessionsController < ApplicationController
  before_filter :authenticate_user!, :except => [:connect]
 
  # Login or Signup via Social Networks
  #  * Twitter login works on localhost
  #  * Facebook login doesn't work on localhost
  def connect
    auth = env["omniauth.auth"]
    new_user = false
    # For Signed in User: Connect Social Networks
    if user_signed_in?

    	logger.debug auth.to_yaml

    	# Cnnect with twitter
    	if auth.provider == 'twitter' and auth.uid.present? and auth.uid.to_i>0

    		# Already used?
	      	@user_twitter = User::TwitterAuth.where('uid=? and user_id!=?', auth.uid.to_i, current_user.id).first

	      	# Yes, rendering view with issue
	      	if @user_twitter.present?
	      		@user = User.find_by_id(@user_twitter.user_id)
	      		@auth = auth

	      	# No, Adding Twitter Connection
	      	else 
	      		ut = User::TwitterAuth.new()
	       		ut.user_id = current_user.id 
	       		ut.uid = auth.uid
	       		ut.name = auth.info.name
	       		ut.revoked = false
	       		ut.secret = auth.credentials.secret
	       		ut.oauth_token = auth.credentials.token
	       		ut.save

	       		# Redirect to settings
	       		redirect_to social_network_settings_path
	      	end 

		  # Connect with Facebook
  		elsif auth.provider == 'facebook' and auth.uid.present? and auth.uid.to_i>0

      		# Already used?
  	      	@user_facebook = User::FacebookAuth.where('uid=? and user_id!=?', auth.uid.to_i, current_user.id).first

  	      	# Yes, rendering view with issue
  	      	if @user_facebook.present?
  	      		@user = User.find_by_id(@user_facebook.user_id)
  	      		@auth = auth

  	      	# No, Adding Facebook Connection
  	      	else 
  	      		uf = User::FacebookAuth.new()
  	       		uf.user_id = current_user.id 
  	       		uf.uid = auth.uid
  	       		uf.name = auth.info.name
  	       		uf.oauth_token = auth.credentials.token
  	       		uf.oauth_expires_at = Time.at(auth.credentials.expires_at)
  	       		if auth.info.email.present?
  		        	uf.email = auth.info.email
  		        end
  	       		uf.save

  	       		# Redirect to settings
  	       		redirect_to social_network_settings_path
  	      	end 
  		end	

	# Not Signed in User: Login or Signup via Social Network
    else

    	logger.debug auth.to_yaml if Rails.env == 'development'

    	# Twitter
    	if auth.provider == 'twitter' and auth.uid.present? and auth.uid.to_i>0

    		# Already Signed Up?
	      	signed = User::TwitterAuth.where('uid = ? and user_id>0', auth.uid.to_i).first
	      	

	      	# Select User to Sign In
	      	if signed.present?
	      		@user = User.find_by_id(signed.user_id)

            #check if oauth & secret are different (e.g. expired)
            if auth.credentials.secret != signed.secret || auth.credentials.token != signed.oauth_token
              signed.secret = auth.credentials.secret
              signed.oauth_token = auth.credentials.token
              signed.save
            end
	       	
	       	# Sign Up
	       	else
            user_params = {
              :title => auth.info.name,
              :twitter_id => auth.uid,
              :bypass_humanizer => true
            }
	       		#u = User.new()
	      		#u.title = auth.info.name
            #u.twitter_id = auth.uid
            u = User.where(twitter_id: auth.uid).first_or_initialize(user_params)
            u.photo = URI.parse(auth.info.image) if auth.info.image? && u.id.nil?
            new_user = true if u.id.nil?
	      		u.save

            @user = u
            uts = User.where(:twitter_id => auth.uid).first

	       		ut = User::TwitterAuth.new()
	       		ut.user_id = uts.id 
	       		ut.uid = auth.uid
	       		ut.name = auth.info.name
	       		ut.revoked = false
	       		ut.secret = auth.credentials.secret
	       		ut.oauth_token = auth.credentials.token
	       		ut.save
	       	end
	       		
	        # Sign In
  			sign_in @user

  			# Remember Me
  			@user.remember_me!

	    # facebook
	    elsif auth.provider == 'facebook' and auth.uid.present? and auth.uid.to_i>0

	    	# Already Signed Up?
	      	signed = User::FacebookAuth.where('uid = ? and user_id>0', auth.uid.to_i).first

	      	# Select User to Sign In
	      	if signed.present? && signed.user
	      		@user = signed.user
	       	# Sign Up
	       	else
            user_params = {
              :title => auth.info.name,
              :bypass_humanizer => true
            }
	       		@user = User.where(email: auth.info.email).first_or_initialize(user_params) 
            @user.photo = URI.parse(auth.info.image) if auth.info.image? && @user.id.nil?
            new_user = true if @user.id.nil?

            @user.skip_confirmation!                    
	      		@user.save

            signed = User::FacebookAuth.new()            
            signed.user_id = @user.id
            signed.uid = auth.uid
            signed.name = auth.info.name
            signed.oauth_token = auth.credentials.token 
            signed.oauth_expires_at = Time.at(auth.credentials.expires_at)
            signed.save          
            if auth.info.email.present?              
              @user.update_attribute(:email, auth.info.email)     
              signed.email = auth.info.email
              signed.save       
            end
            
	       	end

	       	if !@user.present?
	      		logger.info 'Error: @user not defined'
	      	end

	        # Sign In
  			sign_in @user

        # call after sign-in to get IP
        add_to_madmimi({ :email => @user.email, :name => @user.title, :ip => @user.current_sign_in_ip}) if new_user    
        add_to_sendy({ :email => @user.email, :name => @user.title}) if new_user 
  			# Remember Me
  			@user.remember_me!
  			
	    else 
	    	flash.now[:danger] = "Sorry, something went wrong. Please sign in directly using your email." 
	    end

      if new_user
        flash[:tracker] = {
          :event => 'Signup',
          :data => {'Method' => auth.provider}        
        }
        redirect_to wizard_users_path(:step => 1)
      else
        redirect_to root_url
     end
	end
  end

  def disconnect
  	if params['provider']=='twitter'
  		User::TwitterAuth.find_by_user_id(current_user.id).destroy 
  	elsif params['provider']=='facebook'
  		User::FacebookAuth.find_by_user_id(current_user.id).destroy 
  	end

  	redirect_to :back
  end
end