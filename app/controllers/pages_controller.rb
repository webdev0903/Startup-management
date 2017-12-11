class PagesController < ApplicationController
	
	before_filter :authenticate_user!, :except => [:home, :privacy, :terms]

	layout 'landing', :only => [:home]

	def home
		@users = User.active.includes(:profile).where('homepage IS TRUE').order('last_action_at DESC').limit(12)
		# Founders + Cofounders
		# @startup_founders = (User.joins(:owned_startups).uniq + User.joins(:cofounderships).uniq).uniq.count
		#@startup_founders = User.all.count
	end

	def pad
		@post = Post.new
		@posts = current_user.my_pad_posts.page(params[:page])
		@starters = current_user.my_suggested_starters.sort_by { |p| [p.followers.size, p.friends.size] }.reverse!#.order('id DESC')
		@groups = current_user.my_suggested_groups.order('id DESC')
	end

	def privacy
	end

	def terms 
	end

	def contact
		@contact = Contact.new
	end
end
