class CronjobsController < ApplicationController

	def begin

		# Taking Job
		c = Cronjob.where("(next_at < ? and status is true) or (next_at is null and status is true)", Time.now).first

		# Starting
		ms = Time.now
		c.started = c.started + 1
		c.save 

		# Doing
		text = Cronjob.update_user_statistic(c.quantity)
		
		# Ending
		c.ms = Time.now - ms
		text = text + '<br/>Time: ' + c.ms.to_s + ' seconds'
		text.gsub! '<br/>', "\n"
		c.ended = c.ended + 1
		c.answer = text
		c.save

		# Answering
		text.gsub! "\n", '<br/>'
		render :text => text 
	end

	
end