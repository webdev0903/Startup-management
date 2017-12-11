class GroupsController < ApplicationController
  include InactiveUserLimits

  before_filter :authenticate_user!, :except => [:index, :show, :autocomplete]
  before_action :is_active?, :except => [:index, :show, :my_groups, :my_moderated_groups, :join, :leave]

  respond_to :js, :only => [:index, :join, :leave]

  def index
    if params[:qs]
      @query = params[:qs]
      @search = Group.active.search_by_title_about(params[:qs]).includes(:members).search(search_params)    
    else
      @search = Group.active.includes(:members).search(search_params)
    end

    # make name the default sort column
    @search.sorts = 'name' if @search.sorts.empty?
    @groups = @search.result().page(params[:page]).per(12)
  end

  def new
    @group = Group.new
  end

  def create
    @group = current_user.owned_groups.build(params[:group])
    if @group.save
      flash[:success] = 'Group created successfully'
      redirect_to group_path(@group)
    else
      flash[:danger] = @group.errors.full_messages.first
      render :new
    end
  end

  def show
    @group = Group.includes(:members).find_by_url(params[:id])
    @group = Group.includes(:members).find(params[:id]) if @group.blank?
    @post = current_user.posts.build(:group_id => @group.id) if current_user
    @posts = @group.posts.includes(:user, :likes, :comments => [:user]).order('created_at desc')
    @groups = current_user.my_suggested_groups.order('id DESC') if current_user
    @group_members = @group.members.pluck(:id)
    @already_members = current_user.friends.where.not(id: @group_members).order(:title) if current_user
  end

  def autocomplete
    @groups = Group.order("title ilike '%#{params[:qs]}%'").where('title ilike ?', "%#{params[:qs]}%").limit(5)
    output = []
    @groups.each{ |g|
      output.push({
        'title' => g.title,
        'url' => g.url,
        'photo' => g._photo(:thumb)
        })
    }
    render json: output
  end

  def edit
    @group = current_user.owned_groups.find_by_url(params[:id])

  end

  def update
    @group = current_user.owned_groups.find_by_url(params[:id])
    if @group.update_attributes(params[:group])
      flash[:success] = 'Group successfully updated'
      redirect_to group_path(@group) unless remotipart_submitted?
    else
      flash[:danger] = @group.errors.full_messages.first
      render :edit
    end
  end

  def suggest_to_friend
    @group = Group.find_by_url(params[:id])
    params["user_ids"].each do |target_id|
      Notification.generate_for_group_suggest(current_user.id, target_id, @group.id)
    end
    flash[:success] = 'Group successfully suggested'
    redirect_to group_path(@group)
  end

  def my_groups
    #@groups = current_user.groups.includes(:members).page(params[:page]).per(8).order('last_action_at desc')
    @search = current_user.groups.includes(:members).search(search_params)
    # make name the default sort column
    @search.sorts = 'name' if @search.sorts.empty?
    @groups = @search.result().page(params[:page]).per(12)
  end

  def my_moderated_groups
    @groups = current_user.owned_groups.includes(:members).page(params[:page]).per(8).order('last_action_at desc')
  end

  def join
    @group = Group.find_by_url(params[:id])
    @user = User.find(params[:user_id])
    membership = @group.memberships.build(user: @user)
    Notification.generate_for_group_join(current_user.id, @group.id)
    unless membership.save
      @errors = membership.errors.messages.map{|k,v| v.join('<br />')}
      render 'shared/add_error'
    end
  end

  def leave
    @group = Group.find_by_url(params[:id])
    @user = User.find(params[:user_id])
    @group.members.delete(@user)
  end

  def destroy
    @group = current_user.owned_groups.find_by_url(params[:id])
    if @group.destroy
      flash[:success] = 'Your Group has been deleted successfully'
      redirect_to my_moderated_groups_path
    else
      flash[:danger] = @group.errors.full_messages.first
      render :edit
    end
  end

end
