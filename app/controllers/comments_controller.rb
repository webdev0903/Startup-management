class CommentsController < ApplicationController

	before_filter :authenticate_user!
	before_action :is_active?

	def create
		@comment = current_user.comments.create(params[:comment].merge!(:post_id => params[:post_id]))		
		Notification.generate_for_post(@comment.post_id, current_user.id, @comment.id) if @comment.valid?
	end

	def destroy 
		@comment = Comment.find_by_id(params[:id])
		if @comment.owner?(current_user) || current_user.admin
			@comment.destroy
		end
	end

end
