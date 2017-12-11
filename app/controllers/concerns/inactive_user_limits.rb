module InactiveUserLimits
  extend ActiveSupport::Concern

  def inactive_user_check
    unless current_user && current_user.status?
      flash[:error] = I18n.t('.errors.messages.user_is_not_active')
      redirect_to(root_path) 
      return false
    end 
    true
  end
end