class UserFacebooksController < ApplicationController

	def facebook_disconnect
		User::FacebookAuth.find_by_user_id(current_user.id).destroy 
		redirect_to :back
	end
  
end
