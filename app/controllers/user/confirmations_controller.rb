class User::ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      sign_in(resource)
      add_to_madmimi({ :email => resource.email, :name => resource.title, :ip => resource.current_sign_in_ip})
      add_to_sendy({ :email => resource.email, :name => resource.title})
      set_flash_message(:notice, :confirmed) if is_flashing_format?
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
    # sign_in(resource) if resource.errors.empty?
  end
end