class GroupPostsController < ApplicationController
  before_filter :authenticate_user!, only: [:create, :destroy]
  before_action :is_active?

  def create
    #raise params.inspect
    @group = Group.where(url: params[:group_id]).first
    @group = Group.find(params[:group_id]) if @group.blank?

    if @group.members.include?(current_user) || @group.user_id == current_user.id
      @post = @group.posts.create(params[:post].merge(user: current_user))
      Notification.generate_for_group_post(@post.id, current_user.id, params[:group_id]) if @post.valid?
    else
      flash[:error] = "Only members can post in this group."
      redirect_to request.referer.present? ? :back : root_path
      return false
    end
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
