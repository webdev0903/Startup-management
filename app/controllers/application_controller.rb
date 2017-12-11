class ApplicationController < ActionController::Base

  before_filter :configure_permitted_parameters, :if => :devise_controller?
  before_filter :check_notifications
  before_filter :check_messages
  before_filter :check_user_email
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from  ActionView::MissingTemplate, :with => :missing_template
  
  def missing_template(exception)
    if Rails.env.production?
      render :nothing => true, :status => 406
    else
      raise exception
    end
  end

  def check_notifications
    if current_user.present?
      notifications = Notification.where("read = ? and recipient_id = ? ", false, current_user.id)
      @notification_counter = notifications.count
    end
  end

  def check_messages
    if current_user.present?
      messages = Message.where("new = ? and recipient_id = ?", true, current_user.id)
      @messages_counter = messages.count
    end
  end

  def add_to_madmimi(user, list = 'New Users')
    user[:add_list] = list
    mimi = MadMimi.new(Settings.madmimi.email, Settings.madmimi.key)
    mimi.add_user(user)
  end

  def add_to_sendy(user, list ='')
    c = Cindy.new('http://sendy.bigdatatoolbox.com', Settings.sendy.key)
    c.subscribe(Settings.sendy.list, user[:email], user[:name]);
  end

  def is_active?
    if current_user && !current_user.status
      flash[:error] = I18n.t('.errors.messages.user_is_not_active')
      redirect_to request.referer.present? ? :back : root_path
      return false
    end
  end

  def authenticate_admin_user!
    if current_user.nil?
      redirect_to new_user_session_path
      return
    end
    
    if !current_user.admin
      flash[:error] = 'You are not allowed here!'
      redirect_to root_path
      return
    end
  end

  def search_params
    params[:q]
  end
   
  def clear_search_index
    if params[:search_cancel]
      params.delete(:search_cancel)
      if(!search_params.nil?)
        search_params.each do |key, param|
          search_params[key] = nil
        end
      end
    end
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :title << :humanizer_answer << :humanizer_question_id
    end

    def check_user_email
      if current_user && ( action_name != 'email_addresses' ) && !params[:controller].match(/devise|sessions/)
        if !current_user.confirmed? && current_user.email && !current_user.status
          flash.now[:notice] = 'A confirmation email has been sent to the address you provided.  Please click the link in it to activate your account.'
        elsif !current_user.confirmed? && current_user.status
          current_user.confirm!
        end

        if current_user.email.blank?
          redirect_to user_email_addresses_path
        end
        false
      end
    end

end
