class MovesController < ApplicationController
# This controller is for admin use
# to write scripts for tables fixing
  before_filter :authenticate_user!, :except => [:index, :show, :move_passwords_to_old_password]
	

	# CONVERSATIONS
	# Migrate from old system. Make conversations (for the first time)
	# please create all conversations before second steps
	def create_conversations 

		# this is temporary table where we save move steps?
		@moves = Move.where(conversations: nil).limit(500)

		@moves.each do |move|
			# 2. Get user ids with whom I alread have a conversation
			@conversations = Conversation.where(
				'user_id = ? or recipient_id = ?', 
				move.user_id, move.user_id
			)

			@conversation_ids = Array.new
			@conversations.each do |c|
				if c.user_id!=move.user_id
					@conversation_ids.push(c.user_id)
				elsif c.recipient_id!=move.user_id
					@conversation_ids.push(c.recipient_id)
				end
			end
			@conversation_ids = @conversation_ids.uniq

			# 1. Get all user ids I had messages with
			if @conversation_ids.count > 0
				@my_messages = PrivateMessage.where(
					'user_id = ? AND recipient_id NOT IN (?)', 
					move.user_id, @conversation_ids
				)
				@not_my_messages = PrivateMessage.where(
					'recipient_id = ?  AND user_id NOT IN (?)', 
					move.user_id, @conversation_ids
				)
				@birk = 2
			else 
				@my_messages = PrivateMessage.where(
					'user_id = ? or recipient_id = ?', 
					move.user_id, move.user_id
				)
				@birk = 1
			end

			@ids = Array.new

			# add my messages 
			@my_messages.each do |m|
				if m.user_id!=move.user_id
					@ids.push(m.user_id)
				elsif m.recipient_id!=move.user_id
					@ids.push(m.recipient_id)
				end
			end

			# add not mine
			if defined? @not_my_messages 
				@my_messages.each do |m|
					if m.user_id!=move.user_id
						@ids.push(m.user_id)
					elsif m.recipient_id!=move.user_id
						@ids.push(m.recipient_id)
					end
				end
			end


			@ids = @ids.uniq

			# create conversations
			@ids.each do |i|
				if !i.nil?
					Conversation.create(recipient_id: i, user_id: move.user_id)
				end
			end
		
			mov = Move.find(move.id)
			mov.conversations = 1
			mov.save
		end
	end

	# add last message id to conversations
	def get_last_message
		@conversations = Conversation.where(private_message_id: nil).limit(500)

		@conversations.each do |c|
			
			last = PrivateMessage.where(
				'(user_id = ? and recipient_id = ?) OR (recipient_id = ? and user_id = ?)', 
				c.user_id, c.recipient_id, c.user_id, c.recipient_id
			).last
			logger.info(last.inspect)
			if defined? last.id
				con = Conversation.find_by_id(c.id)
				con.private_message_id = last.id
				con.save
			end
		end
	end

	# give conversation_id for private_messages
	def set_conversations
		@moves = Move.where(conversations: 1).limit(800)

		@moves.each do |move|
			conversations = Conversation.where(
				'recipient_id = ?', 
				move.user_id
			)

			conversations.each do |conversation| 
				# 1
				PrivateMessage.where(
					user_id: conversation.user_id, 
				    recipient_id: conversation.recipient_id
				  ).update_all(
				    :conversation_id => conversation.id
				  )

				# 2
				PrivateMessage.where(
				    user_id: conversation.recipient_id,
				    recipient_id: conversation.user_id,
				  ).update_all(
				    :conversation_id => conversation.id
				  )
			end

			mov = Move.find(move.id)
			mov.conversations = nil
			mov.save
		end
	end

	# POSTS
	# fix line breaks
	def fix_line_breaks_posts
		items = Post.all 
		items.each do |i|
			item  = Post.find_by_id(i.id)
			if i.text.present?
				item.text = i.text.gsub('\r\n', "\r\n")
				item.text = item.text.gsub('\n', "\n")
				item.text = item.text.gsub('\r', "\r")
				item.save
			end
		end
	end

	# COMMENT
	# fix line breaks
	def fix_line_breaks_comments
		items = Comment.all 
		items.each do |i|
			item  = Comment.find_by_id(i.id)
			if i.text.present?
				item.text = i.text.gsub('\r\n', "\r\n")
				item.text = item.text.gsub('\n', "\n")
				item.text = item.text.gsub('\r', "\r")
				item.save
			end
		end
	end

	# USER
	# fix line breaks
	def fix_line_breaks_user_parameters
		items = User::Profile.all 
		items.each do |i|
			item  = User::Profile.find_by_id(i.id)
			if i.experience.present?
				item.experience = i.experience.gsub('\r\n', "\r\n")
				item.experience = item.experience.gsub('\n', "\n")
				item.experience = item.experience.gsub('\r', "\r")
				item.save
			end
		end
	end

	# STARTUP
	# fix line breaks
	def fix_line_breaks_startups
		items = Startup.all 
		items.each do |i|
			item  = Startup.find_by_id(i.id)
			if i.about.present?
				item.about = i.about.gsub('\r\n', "\r\n")
				item.about = item.about.gsub('\n', "\n")
				item.about = item.about.gsub('\r', "\r")
				item.save
			end
		end
	end

	# PRIVATE MESSAGES
	def fix_line_breaks_private_messages

		messages = PrivateMessage.all 

		messages.each do |m|
			message  = PrivateMessage.find_by_id(m.id)
			if m.text.present?
				message.text = m.text.gsub('\r\n', "\r\n")
				message.text = m.text.gsub('\n', "\n")
				message.text = message.text.gsub('\r', "\r")
				message.save
			end
		end
	end



	# make slug for keywords
	def make_slugs_for_keywords
		keywords = Keyword.where(url: nil).limit(500)
		keywords.each do |k|
			k = Keyword.find_by_id(k.id)
			k.title = k.title
			k.save
		end
	end

  	# get from starterpad.com
    def photos_for_users
      @users = User.where("status = true and photo_file_name is null and filename is not null and filename !=''").limit(100).order("last_action_at desc")
  
      require 'open-uri'    
      @users.each do |user|
      	if Faraday.head("http://starterpad.com/photos/"+user.filename).status == 200
      	#if File.exists?("http://starterpad.com/photos/"+user.filename)
        	user.photo = URI.parse("http://starterpad.com/photos/"+user.filename)
        	logger.info("http://starterpad.com/photos/"+user.filename)
        	logger.info(user.title)
        	logger.info(user.url)
        else 
        	logger.info("http://starterpad.com/photos/"+user.filename)
        	logger.info()
        	logger.info('Error')
        	logger.info(user.title)
        	user.filename = ''
        end
  		user.save
      end
    end

    # get from starterpad.com
    def photos_for_startups
      startups = Startup.where("status=true and photo_file_name is null and filename!=''").limit(20).order('last_action_at desc')
  
      require 'open-uri'    
      startups.each do |startup|
      	if startup.filename.present? 
      		if Faraday.head("http://starterpad.com/photos/"+startup.filename).status == 200
		        startup.photo = URI.parse("http://starterpad.com/photos/"+startup.filename)
		        startup.save      
		    else 
		    	#startup.filename = ''
		    	logger.info('Error!')
		    end
	    end
	    logger.info("http://starterpad.com/photos/"+startup.filename)
	      logger.info(startup.title)
      end
      render :text => 'Ok'
    end


    # only for one fixing, not include in moves
    def move_passwords_to_old_password
    	users = User.where('sign_in_count'=>0, 'old_password'=>'').limit(300)
    	users.each do |u|
    		u = User.find_by_id(u.id)
    		u.old_password = u.encrypted_password
    		u.encrypted_password = nil
    		u.save
    	end
    end

end
