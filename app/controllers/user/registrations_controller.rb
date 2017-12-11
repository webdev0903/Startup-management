class User::RegistrationsController < Devise::RegistrationsController
  
  protected

    def after_sign_up_path_for(resource)
      flash[:tracker] = {
        :event => 'Signup',
        :data => {'Method' => 'Email'}        
      }
      wizard_users_path(:step => 1)
    end
end