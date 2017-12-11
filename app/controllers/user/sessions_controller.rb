class User::SessionsController < Devise::SessionsController
  prepend_before_filter :verify_user, only: [:destroy]

  private

    def verify_user
      redirect_to new_user_session_path, notice: 'You have already signed out. Please sign in again.' and return unless user_signed_in?
    end
end
