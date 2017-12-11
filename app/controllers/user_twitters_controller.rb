class UserTwittersController < ApplicationController

	def twitter_disconnect
		User::TwitterAuth.find_by_user_id(current_user.id).destroy
		redirect_to :back
	end

end
