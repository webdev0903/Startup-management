class User::FollowershipsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :followings]
  before_action :is_active?, :except => [:index, :followings]
  respond_to :js

  def index
  	@user = User.find_by(:url => params[:url])
    raise ActionController::RoutingError.new('Not Found') if @user.nil?
  	@followers = @user.followers.active.page(params[:page]).per(20)
  end

  def followings
  	@user = User.find_by(:url => params[:url])
  	raise ActionController::RoutingError.new('Not Found') if @user.nil?
  	@followings = @user.followings.active.page(params[:page]).per(20)
  end

	# Follow
	def create
		@to_follow = User.active.find(params[:user_id]) #get the user
		@my_follower = current_user.followers.where(id: @to_follow.id) #check if the users follows me
		if @my_follower.present?
			current_user.followers.destroy(@my_follower)
			@friends = current_user.friends << @to_follow
			current_user.inverse_friends << @to_follow
			 Notification.create({
        user_id: current_user.id,
			  :recipient_id => @to_follow.id, 
			  :friendship_id => @friends.last.friendships.last.id,
			  :key_name => 'follows_back'
			})
		else
			# add notification
      @followingships = current_user.followingships.create(recipient_id: @to_follow.id)
      if @followingships.errors.empty? 
        @followings = current_user.followings
        Notification.create({
          user_id: current_user.id,
          :recipient_id => @to_follow.id, 
          :follower_id => @followingships.id,
          :key_name => 'user_follow'
        })		      
      else
        @errors = @followingships.errors.messages.map{|k,v| v.join('<br />')}

        ## If one of errors caused by inactive user, It will remove other errors messages 
        ## and only return error caused by inactive user 
        if @errors.find{ |e| e.include? I18n.t('.errors.messages.user_is_not_active') }
          @errors.select!{ |e| e.include? I18n.t('.errors.messages.user_is_not_active') }
        end
        render 'shared/add_error'
      end
		end
	end

	def destroy
		@to_unfollow = User.active.find(params[:user_id])
		current_user.followings.destroy(@to_unfollow)
	end

end
