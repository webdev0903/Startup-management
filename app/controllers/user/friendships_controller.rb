class User::FriendshipsController < ApplicationController  
  before_filter :authenticate_user!, :except => [:index]
  before_action :is_active?, :except => [:index, :friends, :my_friends]


  # Show user friends
  def index
    @user = User.find_by(:url => params[:url])
    raise ActionController::RoutingError.new('Not Found') if @user.nil?
    @friends = @user.friends.active.includes(:profile).page(params[:page]).per(20)
  end

  def friends
    @friends = current_user.friends.active.includes(:profile)
  end

  def my_friends
    # Get user_name
    @user = User.find_by_id(current_user.id)

    # Get friendships
    @friendships = Friendship.where(user_id: current_user.id, status: true).order('id desc')#.limit(10)

    friendships = @friendships.map(&:friend_id)

    # Get users
    @users = User.where(id: friendships).order('last_action_at desc')

    # received_friendships
    @received_friendships = Friendship.where(friend_id: current_user.id, status: false).order('id desc')

    # waiting friendships
    @waiting_friendships = Friendship.where(user_id: current_user.id, status: false).order('id desc')

    # Get Followers
    @followers = @user.followers.active

    # Get Followings
    @followings = @user.followings.active#.page(params[:page]).per(20)

    # mark as read notifications
    Notification.where("read is false and recipient_id = ? and key_name = 'friend_request'", current_user.id).update_all(:read => true)

    # nil news sync
    session[:new_sync_at] = nil
  end

  # create a friendship
  def create
    @user = User.find(params[:user_id])
    @friends = current_user.friends << @user
    @friend_request = current_user.sent_friend_requests.last
    # add notification
    Notification.create({
      user_id: current_user.id,
      recipient_id: @user.id,
      :friendship_id => @friend_request.id,
      key_name: 'friend_request'
    })
  end

  # cancel friend request
  def cancel
    @request = Friendship.find(params[:id])
    @request.destroy
  end

  # Accept friend request
  def accept
    @user = User.find(params[:user_id])
    @friends = current_user.friends << @user
    # add notification
    Notification.create({
      user_id: current_user.id,
      recipient_id: @user.id,
      friendship_id: current_user.friendships.last.id,
      key_name: 'friend_accept'
    })
    current_user.followings.delete(@user)
    current_user.followers.delete(@user)
  end

  # Destroy friendship
  def destroy
    @user = User.find(params[:id])
    current_user.friends.destroy(@user)
    current_user.inverse_friends.destroy(@user)
  end
end
