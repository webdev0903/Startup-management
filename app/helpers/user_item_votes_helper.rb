module UserItemVotesHelper
  def link_to_upvote(object)
    link_to vote_item_path(object),remote: true, method: :post, class: 'text-muted' do
      "<i class='fa fa-thumbs-up fa-lg' title='I like this!'></i>".html_safe
    end  
  end

  def link_to_downvote(object)
    link_to vote_item_path(object),remote: true, method: :delete, class: 'text-success' do
      "<i class='fa fa-thumbs-up fa-lg' title='Remove my vote'></i>".html_safe
    end
  end

  def render_votes_for_item(item=nil)
    if current_user && @votes[item.id].include?(current_user.id)
      link_to_downvote(item)
    else
      link_to_upvote(item)
    end
  end

  def render_link_to_user(user, options={})
    if user.status?
      user.username
    else
      link_to user.username, user, options
    end
  end
end
