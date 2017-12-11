ActiveAdmin.register Group do
  permit_params :title, :status, :homepage

  controller do
    def find_resource
      scoped_collection.find_by(url: params[:id])
    end
    def permitted_params
      params.permit!
    end

  end

  member_action :move_to_hp, :method => :get do
    group = Group.find_by(url: params[:id])
    group.homepage = true
    group.save
    redirect_to admin_groups_path, :notice => "Group moved to Homepage!"
  end

  member_action :remove_from_hp, :method => :get do
    group = Group.find_by(url: params[:id])
    group.homepage = false
    group.save
    redirect_to admin_groups_path, :notice => "Group removed from Homepage!"
  end

  member_action :deactivate, :method => :get do
    group = Group.find_by(url: params[:id])
    group.status = false
    group.save
    redirect_to admin_groups_path, :notice => "Group Deactivated"
  end
  member_action :activate, :method => :get do
    group = Group.find_by(url: params[:id])
    group.status = true
    group.save
    redirect_to admin_groups_path, :notice => "Group Activated"
  end

  index do
    selectable_column
    id_column
    column :title
    column "Active", :status
    column "On Homepage", :homepage
    column "On Trending", :trending
    column :created_at
    actions defaults: true do |resource|
      # FIXIT: Need to revisit this shite...
      html = ''
      if resource.status
        html << link_to('Deactivate', deactivate_admin_group_path(resource), :class => 'member_link')
      else
        html << link_to('Activate', activate_admin_group_path(resource), :class => 'member_link')
      end
      if resource.homepage
        html << link_to('Remove from Homepage', remove_from_hp_admin_group_path(resource), :class => 'member_link')
      else
        html << link_to('Move to Homepage', move_to_hp_admin_group_path(resource), :class => 'member_link')
      end
      
      html.html_safe
    end
  end

  filter :status
  filter :title
  filter :homepage
  filter :trending
  filter :created_at


end
