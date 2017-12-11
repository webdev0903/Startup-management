ActiveAdmin.register Startup do
  permit_params :user_id, :title, :summary,:city, :url,:about, :website, :angellist, :twitter, :facebook, :status

  controller do
    def scoped_collection
      Startup.unscoped
    end

    def find_resource
      scoped_collection.find_by(url: params[:id])
    end
    def permitted_params
      params.permit!
    end

  end

  member_action :deactivate, :method => :get do
    startup = Startup.find_by(url: params[:id])
    startup.status = false
    startup.save
    redirect_to admin_startups_path, :notice => "Startup Deactivated"
  end

  member_action :activate, :method => :get do
    startup = Startup.find_by(url: params[:id])
    startup.status = true
    startup.save
    redirect_to admin_startups_path, :notice => "Startup Activated"
  end

  scope :all
  scope :inactive  
  scope :active

  index do
    selectable_column
    id_column
    column :title
    column "Active", :status
    column :created_at
    actions defaults: true do |resource|
      # FIXIT: Need to revisit this shite...
      html = ''
      if resource.status
        html << link_to('Deactivate', deactivate_admin_startup_path(resource), :class => 'member_link')
      else
        html << link_to('Activate', activate_admin_startup_path(resource), :class => 'member_link')
      end
      
      html.html_safe
    end
  end

  filter :status
  filter :title
  filter :created_at

  form do |f|
    f.inputs "Startup Details" do
      f.input :title
      f.input :summary
      f.input :about
      f.input :city
      f.input :country

      f.input :homepage
      f.input :trending
      f.input :owner, :as => :select, :collection => User.active.order("title ASC").all
      f.input :cofounders, :as => :select, :collection => User.active.order("title ASC").all


    end
   
    f.actions
  end
end
