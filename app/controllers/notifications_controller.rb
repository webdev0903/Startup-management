class NotificationsController < ApplicationController
	before_filter :authenticate_user!

	def index 
		@notifications = Notification.where("recipient_id= ? and user_id!= ?", current_user.id, current_user.id).order('id desc').limit(40)

		# mark as read
		Notification.where("read = ? and recipient_id = ?", false, current_user.id).update_all(read: true)
		# nil news sync
		session[:new_sync_at] = nil
	end

	def conjob_send_notifications
		
    	#if @user.profile.next_send
		NotificationMailer.send_notifications.deliver
	end
end
