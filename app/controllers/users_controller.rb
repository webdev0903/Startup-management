class UsersController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :show, :sign_action, :by_keyword, :by_role, :country, :city, :country_auto_complete, :city_auto_complete]
  # before_filter :process_skill_and_markets, :only => [:update]

  # Index
  def index
    @users = User.active.includes(:friends, :followings, :profile => [:country]).page(params[:page])
                 .per(12).order('last_action_at DESC')
    @user_roles = User::Role.order('title ASC')
    @keywords = Keyword.skills.where.not(users_count: nil).limit(13).order('users_count DESC')
    #@users = User.all.page(params[:page]).per(12).order('last_action_at DESC')

  end

  def country
    if request.post?
      title = params[:starter_country_title].to_url
      @country = Country.find_by_url_slug(title) rescue nil
      if @country.nil?
        redirect_to "/starters/country"
      else        
        redirect_to get_by_country_starters_url(@country.url_slug)
      end
    end
    if request.get?
      if params[:title].present?
        title = params[:title].to_url
        @country = Country.find_by_url_slug(title)
        unless @country.present?
          redirect_to get_by_country_starters_path
          return
        end

        @users = User.active.joins(:profile).where("user_parameters.country_id = ?", @country.id)
                     .includes(:profile => :country).page(params[:page]).per(12).order('last_action_at DESC')
      else
        @users = User.active.joins(:profile)
                     .includes(:profile => :country).page(params[:page]).per(12).order('user_parameters.country_id ASC')
      end
      @user_roles = User::Role.order('title ASC')
      @keywords = Keyword.skills.where.not(users_count: nil).limit(13).order('users_count DESC')
      render :index
    end
  end

  def city
    if request.post?
      city_name = params[:starter_city_name].to_url
      redirect_to get_by_city_starters_url(city_name)
    end
    if request.get?
      if params[:name].present?
        @city_name = params[:name].gsub("-", " ").to_s.titleize
        @users = User.active.search_by_city(@city_name)
                     .includes(:profile => :country).page(params[:page]).per(12).order('last_action_at DESC')
      else
        @users = User.active.joins(:profile).includes(:profile => :country).page(params[:page]).per(12)
                     .order('user_parameters.city ASC')

      end
      @user_roles = User::Role.order('title ASC')
      @keywords = Keyword.skills.where.not(users_count: nil).limit(13).order('users_count DESC')
      render :index
    end
  end

  def country_auto_complete
    @countries = Country.order(:title).where("title ILIKE ?", "%#{params[:term]}%")
    render json: @countries.map(&:title)
  end

  def city_auto_complete
    @cities = User::Profile.select(:city).order(:city).where("city ILIKE ?", "%#{params[:term]}%").distinct
    render json: @cities.map(&:city)
  end

  def by_role
    @keyword = User::Role.find_by(:url => params[:role_id])
    @users = User.active.joins(:profile).where("user_parameters.user_role_id = ?", @keyword.id)
                 .includes(:profile => :country).page(params[:page]).per(12).order('last_action_at DESC')
    @user_roles = User::Role.order('title ASC')
    @keywords = Keyword.skills.where.not(users_count: nil).limit(13).order('users_count DESC')
    render :index
  end

  def by_keyword
    @keyword = Keyword.find_by(:url => params[:keyword_id])
    raise ActionController::RoutingError.new('Not Found') if @keyword.nil?
    @users = @keyword.users.active.includes(:profile => :country).page(params[:page]).per(12).order('last_action_at DESC')
    @user_roles = User::Role.order('title ASC')
    @keywords = Keyword.skills.where.not(users_count: nil).limit(13).order('users_count DESC')
    render :index
  end

  # Show
  def show
    @user = User.find_by_url(params[:url])
    @user = User.find(params[:url]) if @user.blank?

    @gem = User::Statistic.find_by(:user_id => @user.id)

    @skills = Keyword.skills.where(:url => @user.profile.skills)
    @user.startups = @user.owned_startups + @user.startups
    if user_signed_in?
      @friend = @user.friends.active.where(:id => current_user.id)
      @friend_request_sent = current_user.sent_friend_requests.where(:friend_id => @user.id).first
      @friend_request_received = current_user.friend_requests.where(:user_id => @user.id).first
      @following = current_user.followings.where(:id => @user.id)
    end
  end

  # Delete
  def deactivate_account

    if params[:confirmed].present?
      User.find(current_user.id).update_attributes({:status => false})
      flash[:danger] = "Your account deactivated successfully."
      redirect_to '/'
    end
  end

  def update
    if current_user.update_attributes(params[:user])
      flash[:success] = "Profile has been updated."
      flash[:tracker] = {
        :event => 'Profile Update'        
      }
      if params[:user][:setting_attributes].present?
        redirect_to :back
        # redirect_to email_settings_path
      else
        redirect_to params[:next] ? params[:next] : :back
      end
    else
      render :profile
    end
  end

  def update_settings    
    if current_user.update_attributes(params[:user])
      flash[:success] = "Your settings have been updated"
      redirect_to :back
    else
      flash[:error] = "An error occurred while updating your settings."
      redirect_to :back
    end
  end

  # Edit
  def profile
  end

  # Edit details
  def profile_details
  end

  # Edit / Change Password
  def change_password
    #raise current_user.inspect
  end

  # Email settings
  def email_settings
    check_settings = current_user.setting
    if check_settings.present?
    else
      @add_new_setting = User::Setting.new(:user_id => current_user.id)
      if @add_new_setting.save
      else
      end
    end
  end

  def social_network_settings
  end

  def twitter_update_settings
    if request.patch?
      current_user.twitter_auth.tweets_per_day = params[:user_twitter_auth][:tweets_per_day]
      flash[:error] = current_user.twitter_auth.errors.messages[:tweets_per_day].join('<br />').html_safe if !current_user.twitter_auth.save
    end
    @profile = current_user.twitter_auth
    if @profile.blank?
      flash[:error] = 'You haven\'t connect your twitter yet'
      redirect_to :social_network_settings
    end

  end

  def email_addresses
    if request.post?
      if !User.email_already_used?(params[:email])
        current_user.update_attributes(email: params[:email])
        current_user.send_confirmation_instructions if current_user.email
        current_user.update_column(:confirmed_at, nil)
        # flash[:error] = 'A confirmation email has been sent to the address you provided.  Please click the link in it to activate your account.'
        redirect_to wizard_users_path(:step => 1)
      else
        flash[:error] = 'The email address has already been used'
      end
    end
  end

  # Fill in Profile - Step 1
  # Join atleast 3 groups - Step 2
  # Connect with twitter - Step 3
  def wizard
    case params[:step]
      when '2'
        @search = Group.active.includes(:members).search(search_params)          
        @search.sorts = 'members_count DESC' if @search.sorts.empty?
        @groups = @search.result().page(params[:page]).per(12)         
    end
    render "users/wizard/step_#{params[:step]}"
  end

  # set timezone, from pad javascript
  def set_timezone
    u = User.find_by_id(current_user.id)
    u.timezone = params[:timezone]
    u.save
    render :layout => false
  end

  # User will ping every 1 min to let us know he is online.
  def ping
    current_user.update_column(:last_action_at, Time.now) if current_user
    render :nothing => true, :status => 204
  end

  def resend_confirmation
    current_user.send_confirmation_instructions
    flash[:success] = 'A confirmation email has been sent to the address you provided.  Please click the link in it to activate your account.'
    redirect_to '/profile'
  end

  private

  def process_skill_and_markets
    params[:user][:profile_attributes][:skills] =
        params[:user][:profile_attributes][:skills].split(',') if params[:user][:profile_attributes] && params[:user][:profile_attributes][:skills].present?
    params[:user][:profile_attributes][:website] =
      params[:user][:profile_attributes][:website].split(',') if params[:user][:profile_attributes] && params[:user][:profile_attributes][:website].present?
    params[:user][:profile_attributes][:markets_interested_in] =
        params[:user][:profile_attributes][:markets_interested_in].split(',') if params[:user][:profile_attributes] && params[:user][:profile_attributes][:markets_interested_in].present?
  end

end
