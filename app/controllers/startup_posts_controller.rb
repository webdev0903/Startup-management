class StartupPostsController < ApplicationController
  before_filter :authenticate_user!, only: [:create, :destroy]
  before_action :is_active?

  def create
    @post = current_user.owned_startups.where(url: params[:startup_id]).first.posts.create(params[:post].merge(user: current_user))    
    Notification.generate_for_startup_post(@post.id, current_user.id, params[:startup_id]) if @post.valid?
  end

  def destroy
    @post = current_user.owned_startups.where(url: params[:startup_id]).first.posts.find(params[:id])
    if @post.destroy
      render :destroy
    else 
      render :undestroyed
    end
  end

  private

    def authenticate_user!
      super
    end

end
