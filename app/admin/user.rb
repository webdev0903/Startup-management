ActiveAdmin.register User do
  permit_params :email, :title, :password, :password_confirmation, :status, :homepage, :timezone

  controller do
    def find_resource
      scoped_collection.find_by(url: params[:id])
    end
    def permitted_params
      params.permit!
    end

    def update
      if !resource.status && params[:user][:status].to_i
        UserMailer.active_profile(resource.id).deliver
      end
      super
    end
  end

  member_action :move_to_hp, :method => :get do
    user = User.find_by(url: params[:id])
    user.homepage = true
    user.save
    redirect_to admin_users_path, :notice => "User moved to Homepage!"
  end

  member_action :remove_from_hp, :method => :get do
    user = User.find_by(url: params[:id])
    user.homepage = false
    user.save
    redirect_to admin_users_path, :notice => "User removed from Homepage!"
  end

  member_action :review_profile, :method => :get do
    user = User.find_by(url: params[:id])
    user.update_column(:activable, false) #don't use update_attribute, it will trigger after_save callback
    UserMailer.review_profile(user.id).deliver
    redirect_to admin_users_path, :notice => "Email sent to user to review his profile!"
  end

  member_action :deactivate, :method => :get do
    user = User.find_by(url: params[:id])
    user.status = false
    user.save
    redirect_to admin_users_path, :notice => "User Deactivated"
  end
  member_action :activate, :method => :get do
    user = User.find_by(url: params[:id])
    user.status = true
    user.save
    UserMailer.active_profile(resource.id).deliver
    redirect_to admin_users_path, :notice => "User Activated"
  end

  member_action :resend_confirmation, :method => :get do
    resource.send_confirmation_instructions
    redirect_to admin_users_path, :notice => "Confirmation email sent to #{resource.email}"
  end

  scope :all
  scope :inactive
  scope :activable
  scope :active

  index do
    selectable_column
    id_column
    column :email
    column :title
    column "Active", :status
    column "On Homepage", :homepage
    column :created_at
    actions defaults: true do |resource|
      # FIXIT: Need to revisit this shite...
      html = ''
      if resource.status
        html << link_to('Deactivate', deactivate_admin_user_path(resource), :class => 'member_link')
      else
        html << link_to('Activate', activate_admin_user_path(resource), :class => 'member_link')
      end
      if resource.homepage
        html << link_to('Remove from Homepage', remove_from_hp_admin_user_path(resource), :class => 'member_link')
      else
        html << link_to('Move to Homepage', move_to_hp_admin_user_path(resource), :class => 'member_link')
      end
      html << link_to('Review Profile', review_profile_admin_user_path(resource), :class => 'member_link')
      if resource.confirmed_at.nil?
        html << link_to('Resend Confirmation', resend_confirmation_admin_user_path(resource), :class => 'member_link')
      end
      html.html_safe
    end
  end

  sidebar "Photo", :only => :show do |resource|
    attributes_table_for user do
      div do
        image_tag user._photo(:middle)
      end
    end
  end

  show do |user|
    panel "User Details" do
      attributes_table_for user  do
        row :id
        row :email
        row :title
        row :country do
          user.profile.country.try(:title)
        end
        row :city do
          user.profile.city
        end
        row :role do
          user.profile.role.try :title
        end
        row :profession do
          user.profile.summary
        end
        row :current_position do
          user.profile.current_position
        end
        row :skills do
          Keyword.skills.where(:url => user.profile.skills).map(&:title).join(', ')
        end
        row :interested_in_markets do
          Keyword.markets.where(:url => user.profile.markets_interested_in).map(&:title).join(', ')
        end
        row :looking_for do
          user.profile.looking_for
        end
        row :experience do
          user.profile.experience
        end
        row :last_action_at
        row :timezone
        row :sign_in_count
        row :current_sign_in_at
        row :current_sign_in_ip
        row :last_sign_in_ip
        row "On Homepage", :homepage
        row :confirmed_at
        row :created_at
        row :updated_at
      end
    end
  end


  filter :email
  filter :status
  filter :title
  filter :homepage
  filter :created_at

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :title
      f.input :password
      f.input :password_confirmation
      # f.input :confirmed_at, :as => :check_boxes, :collection => [f.object.confirmed_at] , :input_html => { disabled: true }
      f.input :status
      f.input :homepage   
      f.semantic_fields_for  :profile do |profile|
        profile.input :country
        profile.input :city
      end   
      f.input :timezone, :as => :select, :collection => ActiveSupport::TimeZone.all.sort
    end
   
    f.actions
  end

end
