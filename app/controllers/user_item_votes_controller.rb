class UserItemVotesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  before_filter :is_active?, :except => [:index]  
  before_action :set_item

  def create
    if current_user.votes.build(vote_params).save
      redirect_to :back, notice: "Upvoted."
    else
      redirect_to :back, notice: "Already Upvoted."
    end
  end

  def destroy
    vote = current_user.votes.where(vote_params).first
    if vote
      vote.destroy
      message = 'Removed Vote.'
    else
      message = 'No vote to remove.'
    end
    redirect_to :back, notice: message
  end

  private
  def set_item
    @item = Item.find_by_uri(params[:id])
    unless @item
      return redirect_to :back, notice: "Could not find item with #{params[:id]}"
    end
  end

  def vote_params
    {
      votable_id: @item.id,
      votable_type: @item.class.to_s
    }
  end
end
