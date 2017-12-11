module NotificationsHelper
	def notificationParam(n,htmlFormat)
		case n.key_name
			when 'friend_request'
				title = 'sent you a connection request'

			when 'friend_accept'
				title = 'accepted your connection request'

			when 'follows_back'
				title = 'followed you back. You made a connection!'

			when 'user_follow'
				title = 'started following you'

			when 'post_comment'
				title = 'commented on "'+'<a href="'+url_for(post_url(n.post.id))+'">'+truncate(n.post.text, :lenght=>40)+'</a>"'
			
			when 'post_like'
				title = 'gave you a gem for your post'

			when 'startup_post'
				
				if n.startup.present? and n.startup.url.present?
					post = n.post
					title = 'posted in <a href="'+ url_for(startup_url(n.startup.url))+'">'+n.startup.title+'</a> Startup page<br />' + truncate(post.text.to_s, length: 103)
				end

			when 'startup_follow'
				
				if n.startup.present? and n.startup.url.present?
					title = 'started following <a href="'+ url_for(startup_url(n.startup.url))+'">'+n.startup.title+'</a>'
				end

			when 'group_follow'
				
				if n.group.present? and n.group.url.present?
					title = 'started following <a href="'+ url_for(group_url(n.group.url))+'">'+n.group.title+'</a>'
				end

			when 'group_join'
				if n.group.present?
					title = 'joined your group '+ n.group.title
				else
					n.delete
				end
			when 'group_post'
				title = 'posted in your group ' + link_to(n.group.title, group_url(n.group))
			when 'suggest_group'
				title = 'suggested that you join the group ' + link_to(n.group.title, group_url(n.group))

			when 'group_comment'
				title = 'commented on your post in xxx'
			when 'group_post_like'
				title = 'liked your post in xxx'
		end
		
		# web
		if htmlFormat == 'web'
			if title.present? and n.user.present?

				# photo
				if n.user.present? and n.user.photo.present?
					photoDiv = '<div class="notificationTabPhoto">
								<a href="' + url_for(profile_url(n.user.url)) + '">
									'+ image_tag(n.user.photo.url(:thumb))+ '
								</a>
							</div>'

				else
					photoDiv = ''
				end

				# link text
				if defined? link and link.present?
					linkDiv = '<a href="' + url_for(link) + '">
								' + title + '
								</a>'
				else 
					linkDiv = title
				end

				# html source
				htmlCode = '<div class="notificationTab">
			  				' + photoDiv + '
							<div class="notificationTabText">
								<span>
									<a href="' + url_for(profile_url(n.user.url)) + '">
										' + n.user.title + '
									</a>
								</span>

								' + linkDiv
				if n.created_at.present?
					htmlCode = htmlCode + '
							<div class="notificationTabDate">
								'+time_ago_in_words(n.created_at).to_s+' ago
							</div>'
						
				end 

				htmlCode = htmlCode+ '
								</div>
							</div>
						<div style="clear:both"></div>'

				return htmlCode.html_safe
			end

		# mail
		elsif htmlFormat == 'mail'
			if title.present? and n.user.present?

				# photo
				if n.user.present? and n.user.photo.present?
					photoDiv = '<div style="float:left;">
								<a href="' + url_for(profile_url(n.user.url)) + '">
									'+ image_tag(n.user.photo.url(:thumb), 'style'=>'width:50px; margin-right:10px;')+ '
								</a>
							</div>'

				else
					photoDiv = ''
				end

				# link text
				if defined? link and link.present?
					linkDiv = '<a href="' + url_for(link) + '">
								' + title + '
								</a>'
				else 
					linkDiv = title
				end

				# html source
				htmlCode = '<div style="padding:10px; display:table; width:500px; border-bottom:1px solid rgb(240,240,240)">
			  					' + photoDiv + '
								<div class="float:left; width:450px;">
									<span>
										<a href="' + url_for(profile_url(n.user.url)) + '">
											' + n.user.title || 'a user' + '
										</a>
									</span>
									' + linkDiv + '
								</div>'
				if n.created_at.present?
					htmlCode = htmlCode + '
							<div style="float:right">
								'+time_ago_in_words(n.created_at).to_s+' ago
							</div>'
						
				end 

				htmlCode = htmlCode+ '</div>
						<div style="clear:both"></div>'

				return htmlCode.html_safe
			end
		end
	end

	def notification_generator(notification)
		atext = ''
		btext = ''
		title = ''
		ttext = ''
		url = '#'
		case notification.key_name
			when 'friend_request'
				title = notification.user.title
				btext = ' sent you a connection request'
				url = profile_url(notification.user) rescue '#'
			when 'friend_accept'
				title = notification.user.try(:title)
				btext = ' accepted your connection request'
				url = profile_url(notification.user) rescue '#'
			when 'follows_back'
				title = notification.user.try(:title)
				btext = ' followed you back. You made a connection!'
				url = profile_url(notification.user) rescue '#'
			when 'user_follow'
				title = notification.user.try(:title)
				btext = ' started following you'
				url = profile_url(notification.follower) rescue '#'
			when 'post_comment'
			  u_url = profile_url(notification.user) rescue '#'
				atext = link_to(notification.user.try(:title), u_url) + ' commented on "' 
				title = truncate(notification.post.try(:text).to_s, :lenght=>40) + '"'
				url = post_url(notification.post) rescue '#'
			when 'post_like'
			  u_url = profile_url(notification.user) rescue '#'
				atext = link_to(notification.user.try(:title), u_url) + ' gave you a gem for your '
				title = 'post'
				url = post_url(notification.post) rescue '#'
			when 'startup_post'
				if notification.startup.present? and notification.startup.url.present?
					u_url = profile_url(notification.user) rescue '#'
					post = notification.post
					atext = link_to(notification.user.try(:title), u_url) + ' posted in '
					title = notification.startup.title
					#title = notification.user.try(:title) + ' posted in ' + notification.startup.title
					ttext = truncate(post.text.to_s, length: 103)
					url = startup_url(notification.startup) rescue '#'
				end
			when 'startup_follow'
				if notification.startup.present? and notification.startup.url.present?
				  u_url = profile_url(notification.user) rescue '#'
					atext = link_to(notification.user.try(:title), u_url) + ' started following '
					title = notification.startup.try(:title).to_s
					url = startup_url(notification.startup) rescue '#'
				end
			when 'group_follow'
				if notification.group.present? and notification.group.url.present?
				  u_url = profile_url(notification.user) rescue '#'
					atext = link_to(notification.user.try(:title), u_url) + ' started following '
					title = notification.group.try(:title).to_s
					url = group_url(notification.group) rescue '#'
				end
			when 'group_join'
				if notification.group.present?
				  u_url = profile_url(notification.user) rescue '#'
					atext = link_to(notification.user.try(:title), u_url) +' joined your group '
					title = notification.group.try(:title).to_s
					url = group_url(notification.group) rescue '#'
				else
					notification.delete
				end
			when 'group_post'
				u_url = profile_url(notification.user) rescue '#'
				post = notification.post
				atext = link_to(notification.user.try(:title), u_url) + ' posted in '
				title = notification.group.try(:title)
				ttext = truncate(post.text.to_s, length: 103)
				url = group_url(notification.group) rescue '#'
			when 'suggest_group'
				u_url = profile_url(notification.user) rescue '#'
				atext = link_to(notification.user.try(:title), u_url) + ' suggested that you join the group '
				title = notification.group.try(:title)
				url = group_url(notification.group) rescue '#'
			when 'group_comment'
			  u_url = profile_url(notification.user) rescue '#'
				atext =link_to(notification.user.try(:title), u_url) + ' commented on your post in '
				title = notification.group.try(:title)
				url = group_url(notification.group) rescue '#'
			when 'group_post_like'
			  u_url = profile_url(notification.user) rescue '#'
				atext = link_to(notification.user.try(:title), u_url) + ' liked your post in '
				title = notification.group.try(:title).to_s
				url = group_url(notification.group) rescue '#'
		end
		image = image_tag(notification.user.try('_photo', :small) || notification.follower.try('_photo', :small), style: "border-top-left-radius: 3px; border-top-right-radius: 3px; border-bottom-right-radius: 3px; border-bottom-left-radius: 3px; max-width: 2195px;")
		notif_url = profile_url(notification.user || notification.follower) rescue '#'
		link_to(image, notif_url, target: 'blank') + ' ' + link_to(title, url)

		(%{
			  <div style="width:500px;border-top:1px solid rgba(0,0,0,0.06)">
			    <div style="min-height:10px"></div>
			    <div style="float:left;width:50px">
		} + 
		link_to(image, notif_url, target: 'blank') + 
		'</div>' + 
		%{
			<div style="float:left;width:450px">
			} +
			atext + '' + link_to(title, url) + '' + btext +
		  '<br />' + ttext +
		  '</div>' +			 
		%{
				  <div style="clear:both"></div>
				  <div style="min-height:10px"></div>
				</div>
		}).html_safe
	end

end
