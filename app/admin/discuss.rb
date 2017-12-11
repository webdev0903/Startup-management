ActiveAdmin.register Item do
  permit_params :title, :content, :url

  controller do
    def find_resource
      scoped_collection.find_by(uri: params[:id])
    end
    def permitted_params
      params.permit!
    end

  end


  member_action :deactivate, :method => :get do
    item = Item.find_by(uri: params[:id])
    item.disabled = true
    item.save
    redirect_to admin_items_path, :notice => "Item Deactivated"
  end
  member_action :activate, :method => :get do
    item = Item.find_by(uri: params[:id])
    item.disabled = false
    item.save
    redirect_to admin_items_path, :notice => "Item Activated"
  end

  index do
    selectable_column
    id_column
    column :title
    column "Disabled", :disabled
    column :created_at
    actions defaults: true do |resource|
      # FIXIT: Need to revisit this shite...
      html = ''
      if !resource.disabled
        html << link_to('Deactivate', deactivate_admin_item_path(resource), :class => 'member_link')
      else
        html << link_to('Activate', activate_admin_item_path(resource), :class => 'member_link')
      end
      html.html_safe
    end
  end

  filter :status
  filter :title
  filter :created_at

  form do |f|
    f.inputs "Item Details" do
      f.input :title
      f.input :url
      f.input :content      
    end
   
    f.actions
  end

end
