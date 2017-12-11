class StartupsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:index, :show, :by_market, :country, :city, :country_auto_complete, :city_auto_complete]
  before_action :is_active?, :except => [:index, :show, :by_market, :my_startups, :country, :city, :country_auto_complete, :city_auto_complete]
  #before_filter :process_skill_and_markets, :only => [:create, :update]

	# List
	def index
    #<<<<<<< HEAD
    #@startups = Startup.includes(:country, :cofounders, :followers).page(params[:page]).per(12).order('last_action_at desc')
    #@startups = Startup.order(title: :desc).includes(:country, :cofounders, :followers).page(params[:page]).per(12).order('last_action_at desc')
    #@startups.order("id ASC")
    #@search = Startup.includes(:country, :cofounders, :followers, :statistic).search(search_params)
    # make name the default sort column
    #=======
    if params[:qs]
      @query = params[:qs]
      @search = Startup.includes(:country, :cofounders, :followers, :statistic).search_by_title_about(params[:qs]).search(search_params)    
    else
      @search = Startup.includes(:country, :cofounders, :followers, :statistic).search(search_params)
    end

    #>>>>>>> dev
    @search.sorts = 'name' if @search.sorts.empty?
    @startups = @search.result().page(params[:page]).per(12)
  end

  def by_market
    markets = params[:market_id].split(',')
    @markets = Keyword.markets.where(:url => markets)
    #@search = Startup.includes(:country, :cofounders, :followers).where("ARRAY[?]::varchar[] && markets", markets).page(params[:page]).per(8).order('last_action_at desc')
    @search = Startup.includes(:country, :cofounders, :followers).where("ARRAY[?]::varchar[] && markets", markets).search(search_params)
    # make name the default sort column
    @search.sorts = 'name' if @search.sorts.empty?
    @startups = @search.result().page(params[:page]).per(12)
    render :index
  end

  def country
    if request.post?
      title = params[:startup_country_title].to_url
      @country = Country.find_by_url_slug(title) rescue nil
      if @country.nil?
        redirect_to "/startups/country"
      else        
        redirect_to get_by_country_startups_url(@country.url_slug)
      end
    end
    if request.get?
      if params[:title].present?
        title = params[:title].to_url
        @country = Country.find_by_url_slug(title)
        unless @country.present?
          redirect_to get_by_country_startups_path
          return
        end
        @search = Startup.where("startups.country_id = ?", @country.id).includes(:country, :cofounders, :followers).search(search_params)                
      else
        @search = Startup.includes(:country, :cofounders, :followers).search(search_params)
      end
      @search.sorts = 'name' if @search.sorts.empty?
      @startups = @search.result().page(params[:page]).per(12)      
      render :index
    end
  end

  def city
    if request.post?
      city_name = params[:startup_city_name].to_url
      redirect_to get_by_city_startups_url(city_name)
    end
    if request.get?
      if params[:name].present?
        @city_name = params[:name].gsub("-", " ").to_s.titleize
        @search = Startup.search_by_city(@city_name).includes(:country, :cofounders, :followers).search(search_params)                                
      else
        @search = Startup.includes(:country, :cofounders, :followers).search(search_params)
      end
      @search.sorts = 'name' if @search.sorts.empty?
      @startups = @search.result().page(params[:page]).per(12)      
      render :index
    end
  end

  def autocomplete
    @startups = Startup.order("title ilike '%#{params[:qs]}%'").where('title ilike ?', "%#{params[:qs]}%").limit(5)
    output = []
    @startups.each{ |g|
      output.push({
        'title' => g.title,
        'url' => g.url,
        'photo' => g._photo(:thumb)
        })
    }
    render json: output
  end

  def country_auto_complete
    @countries = Startup.includes(:country).order('countries.title').where("countries.title ILIKE ?", "%#{params[:term]}%").group('countries.title').limit(10).distinct.count
    render json: @countries
  end

  def city_auto_complete
    @cities = Startup.order(:city).where("city ILIKE ?", "%#{params[:term]}%").group(:city).limit(10).distinct.count
    render json: @cities
  end

  def my_startups
    @startups = current_user.owned_startups.includes(:country, :cofounders, :followers).page(params[:page]).per(8).order('last_action_at desc')
    @search = current_user.owned_startups.includes(:country, :cofounders, :followers).search(search_params)
    # make name the default sort column
    @search.sorts = 'name' if @search.sorts.empty?
    @startups = @search.result().page(params[:page]).per(12)
    render :index
  end

	# Show
	def show
    @startup = Startup.includes(:country, :posts).find_by_url(params[:id])
    @startup = Startup.includes(:country, :posts).find(params[:id]) if @startup.blank?
    @post    = Post.new
    @markets = Keyword.markets.where(:url => @startup.markets)
  end
  
	def new 
		@startup = Startup.new
	end

	def edit 
		@startup = current_user.owned_startups.find_by_url(params[:id])
	end

  def create
    @startup = current_user.owned_startups.build(params[:startup])
    if @startup.save
      @last = Startup.last
      Startup::Statistic.create({:startup_id => @startup.id, :followers_count => 0})
      redirect_to startup_path(@startup)
    else
      flash[:danger] = @startup.errors.full_messages.first
      render :new
    end
  end

  def update 
    @startup = current_user.owned_startups.find_by_url(params[:id])
    if @startup.update_attributes(params[:startup])
      flash[:success] = 'Your Startup has been updated successfully'
      redirect_to startup_path(@startup)
    else
      flash[:danger] = @startup.errors.full_messages.first
      render :edit
    end

  end

	def destroy 
		@startup = current_user.owned_startups.find_by_url(params[:id])
    if @startup.destroy
      flash[:success] = 'Your Startup has been deleted successfully'
  		redirect_to my_startups_startups_path
    else
      flash[:danger] = @startup.errors.full_messages.first
      render :edit
    end
	end

  def follow
    @startup = Startup.where(url: params[:id]).first
    #raise @startup.id
    
    unless current_user.follow_startup(@startup)
      flash[:error] = I18n.t('.errors.messages.user_is_not_active')
    end
    Notification.generate_for_startup_follow(current_user.id, params[:id])
    if @startup.statistic
      followers_count = @startup.followers.count
      @startup.statistic.update_attribute(:followers_count, followers_count)
    else
      #raise "AAA"
      followers_count = @startup.followers.count
      #raise followers_count.inspect
      Startup::Statistic.create({:startup_id => @startup.id, :followers_count => followers_count})
      #a.save
    end
    redirect_to :back
  end

  def unfollow
    @startup = Startup.where(url: params[:id]).first
    #raise @startup.id
    current_user.unfollow_startup(@startup)
    if @startup.statistic
      followers_count = @startup.followers.count
      @startup.statistic.update_attribute(:followers_count, followers_count)
    else

      followers_count = @startup.followers.count
      #raise followers_count.inspect
      Startup::Statistic.create({:startup_id => @startup.id, :followers_count => followers_count})
      #a.save
    end
    redirect_to :back
  end
  private

    def process_skill_and_markets
      params[:startup][:markets] =
        params[:startup][:markets].split(',') if params[:startup][:markets].present?
      params[:startup][:cofounder_ids] =
        params[:startup][:cofounder_ids].split(',') if params[:startup][:cofounder_ids].present?
    end
end
