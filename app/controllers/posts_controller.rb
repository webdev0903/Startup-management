class PostsController < ApplicationController

	before_filter :authenticate_user!
	before_action :is_active?, :except => [:index, :likes]

	include ActionView::Helpers::TextHelper

	def index		
		@posts = current_user.my_pad_posts.page(params[:page])
	end

	def show		
		@post = Post.where('id = ?', params[:id]).first or raise ActionController::RoutingError.new('Not Found')
	end

	def create
		@post = current_user.posts.create(params[:post])
		Notification.generate_for_group_post(@post.id, current_user.id, @post.group_id) if @post.group_id != nil
	end

	# TODO: Make a view
	def likes
		@post = Post.find(params[:id])
		@likes = @post.likes
	end

	def update

		# Like
		if defined? params[:do] and params[:do] == 'like' and params['id'].present? and user_signed_in?

			# check for duplicate
			like = Like.where(post_id: params['id'], user_id: current_user.id)
			post_hash = Digest::SHA2.hexdigest((params['id'].to_i+2000).to_s + current_user.id.to_s)

			if !like.present? and post_hash == params['post_hash']

			  # add like
			  l = Like.new()
			  l.post_id = params['id']
			  l.user_id = current_user.id
			  l.recipient_id = params['user_id']
			  l.save

			  # update number of likes for post
			  p = Post.find_by_id(params['id'])
			  p.likes_count = params['likes_count']
			  p.save

			  # create notification
			  Notification.new_notification({
			  	user_id: current_user.id, 
			  	recipient_id: params['user_id'],
			  	post_id: params['id'],
			  	like_id: l.id, 
			  	key_name: 'post_like'
			  })
			end

		elsif defined? params[:do] and params[:do] == 'unlike' and params['id'].present?
			like = Like.where(post_id: params['id'], user_id: current_user.id).first

			if like.present? and like.user_id == current_user.id

				# remove like
				like.destroy()

				# update number of likes for post
			    p = Post.find_by_id(params['id'])
			    p.likes_count = params['likes_count']
			    p.save
			end
		end
		render :json => 'ok'
	end

	def destroy 
		@post = Post.find_by_id(params[:id])
		if @post.user_id == current_user.id || current_user.admin
			@post.destroy
		else 
			render :json => 'error'
		end
		
	end
end