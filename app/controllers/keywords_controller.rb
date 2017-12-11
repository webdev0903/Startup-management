class KeywordsController < ApplicationController

  respond_to :json, :html

	def index
		if params[:for] == 'market'
			@keywords = Keyword.markets.where("startups_count > 0").select([:id, :title, :url, :startups_count, :followers_count])
		else 
			@keywords = Keyword.skills.where("users_count > 0").select([:id, :url, :title, :users_count]).limit(5)
		end
		@keywords.each do |k|
			if k.title.blank?
				k.title = "No Name"
			else
				k.title = k.title.capitalize
			end
		end
		respond_with(@keywords)
	end

	def list 
		@keywords = Keyword.skills.where("users_count > 9").order('title asc').limit(200)
	end
end
