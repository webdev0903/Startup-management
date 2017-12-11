class ConversationsController < ApplicationController
  
  before_filter :authenticate_user!
  before_action :is_active?, :except => [:index]

  # All conversations
  def index
    @conversations = Conversation.includes(:last_message, :sender, :receiver).where(
      "(user_id = ? AND user_hide IS NOT TRUE) OR (recipient_id = ? AND recipient_hide IS NOT TRUE)",
    current_user.id, current_user.id).order('updated_at DESC').page(params[:page]).per(10)
  end

  def create    
    @conversation = Conversation.new(params[:conversation])
    if @conversation.save
      flash[:success] = 'Your Message has been sent successfully'
      send_conversation_email(@conversation)
      redirect_to conversation_path(@conversation.recipient_id)
    else
      flash[:danger] = 'There was an error, Please try again!'
      redirect_to conversation_path(@conversation.recipient_id)
    end
  end

  def update
    @conversation = Conversation.find(params[:id])
    if @conversation.recipient_id === current_user.id 
      recipient = @conversation.user_id
    else
      recipient =  @conversation.recipient_id
    end

    data = {
      "messages_attributes" => {
        "0" => {
          "text" => params[:conversation][:messages_attributes]["0"][:text],
          "user_id" => current_user.id,
          "recipient_id" => recipient
        }
      }
    }
    if @conversation.update_attributes(data)
      flash[:success] = 'Your Message has been sent successfully'
      send_conversation_email(@conversation)
      redirect_to conversation_path(recipient)
    else
      flash[:danger] = 'There was an error, Please try again!'
      redirect_to conversation_path(recipient)
    end
  end

  # Hide
  def hide
    conversation = Conversation.find(params[:id])

    conversation.user_id == current_user.id ? conversation.user_hide = true : conversation.recipient_hide = true
    conversation.messages.update_all(:new => false) if conversation.save

    flash[:success] = "Done!"
    redirect_to conversations_url
  end

  def show
    @user = User.find(params[:id])
    if @user == current_user      
      redirect_to '/conversations'
      return
    end

    @conversation = Conversation.with(current_user, @user)
    if @conversation.blank?
      @conversation = Conversation.new(:recipient_id => @user.id, :user_id => current_user.id)
      @messages = []
    else
      @messages = @conversation.messages.sort_by &:created_at
      Message.where("recipient_id = ? and user_id = ? and new = true ", current_user.id, @user.id).update_all(:new => false)
    end

    @message = Message.new(:recipient_id => @user.id, :user_id => current_user.id)
  end

  protected

  def send_conversation_email(conversation)
    @receiver = conversation.last_message.receiver
    if !@receiver.online? &&  @receiver.setting.private_messages
      UserMailer.new_message(conversation.last_message).deliver
    end
  end

end
