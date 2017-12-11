class LikesController < ApplicationController

  before_filter :authenticate_user!
  before_action :is_active?
  
  def create
    @like = current_user.likes.create(params[:like])
    Notification.generate_for_post_like(current_user.id, @like.post_id)
  end

  def destroy
    @like = Like.find(params[:id])
    @like.destroy
  end
end
