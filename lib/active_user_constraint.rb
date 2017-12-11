class ActiveUserConstraint
  def self.matches?(request)
  	current_user = request.env['warden'].user :scope => :user
  	if current_user && current_user.admin
  		User.where(url: request.params[:url]).present? 
  	else	
    	User.active.where(url: request.params[:url]).present? 
    end
  end
end