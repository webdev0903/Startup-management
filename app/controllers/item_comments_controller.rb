class ItemCommentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  before_filter :is_active?, :except => [:index]  
  before_filter :set_item

  def index
    @comments = @item.comments.order(created_at: :asc)
  end

  def create
    @comment = current_user.item_comments.build(comment_params)
    if @comment.save
      redirect_to item_path(@item), notice: "Your comment has been posted"
    else
      redirect_to item_path(@item), notice: @comment.errors.full_messages.join(". ")
    end
  end

  def update
  end

  def destroy
  end

  private

  def set_item
    @item = Item.find_by_uri(params[:item_id])
    return redirect_to items_path, notice: 'could not find item' unless @item
  end

  def comment_params
    params.require(:item_comment).permit(:content).merge({item_id: @item.id})
  end
end
