class ContactController < ApplicationController

  def index
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])
    @contact.bypass_humanizer = true if user_signed_in?
    if @contact.valid?
      @contact.inform_support
      flash[:success] = "Your message has been sent successfully!"
      redirect_to contact_index_path
    else
      flash[:danger] = @contact.errors.full_messages.first
      render :index
    end
  end
end
