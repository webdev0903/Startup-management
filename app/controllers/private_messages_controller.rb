class PrivateMessagesController < ApplicationController
  	before_filter :authenticate_user!
  	before_action :is_active?, :except => [:index]

	# Send message
	def create
	  params[:private_message][:new] = 1
	  message = current_user.messages.build(params[:private_message])
	  conversation = Conversation.where(
			'(user_id = ? and recipient_id = ?) OR (recipient_id = ? and user_id = ?)', 
			current_user.id, message.recipient_id, current_user.id, message.recipient_id
		).first

		conversation.create() if conversation.blank?


	  # Save
	  if @private_message.save
	    flash[:success] = "Message has been sent."
	  
		  # Get conversation

		  # Create conversation
		  if !con.present?
		  	con = Conversation.new
		  	con.user_id = current_user.id
		  	con.recipient_id = params[:private_message][:recipient_id]
		  	con.private_message_id = @private_message.id
		  	con.save

		  # Add last message
		  else 
		  	con = Conversation.find(con[:id])
		  	con.private_message_id = @private_message.id
		  	con.user_hide = false
		  	con.recipient_hide = false
		  	con.save
		  end

		  # Update conversation_id for message
		  @private_message.conversation_id = con.id
		  @private_message.save

	  end

	  redirect_to conversation_url(params[:private_message][:recipient_id])
	end

	# Show conversation with selected user
	def index 
		@user = User.find_by(:url => params[:id])
		@messages = PrivateMessage.where(
			'(user_id = ? and recipient_id = ?) OR (recipient_id = ? and user_id = ?)', 
			current_user.id, @user.id, current_user.id, @user.id
		).order('id asc')

		# for form
		@private_message = PrivateMessage.new(:recipient_id => @user.id)

		# mark as read
		# PrivateMessage.where("recipient_id = ? and user_id = ? and new = ? ", current_user.id, @user.id, true).update_all(new: false)
	
		# nil news sync
		session[:new_sync_at] = nil
	end
end
