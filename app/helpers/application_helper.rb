require 'uri'

module ApplicationHelper
  def twitter_update_frequencies_for_select
    {'Turned off' => 0,
     '1 Tweet per day' => 1,
     '2 Tweets per day' => 2,
     '3 Tweets per day' => 3}
  end

  def twitter_update_frequencies_status(count)
    return 'Turned off' if count.to_i == 0
    'Active'
  end

  def ucwords str
    str.split(' ').select {|w| w[0] = w[0].upcase }.join(' ');
  end

  def nav_link(link_text, fa_icon, link_path)
    class_name = current_page?(link_path) ? 'current' : nil

    content_tag(:li, :class => class_name) do
      link_to link_path do
        "<i class='fa fa-#{fa_icon}'></i>".html_safe + " " + link_text
      end
    end
  end

  def is_admin?
    return current_user && current_user.admin
  end

  def nav_icon_link(link_text, fa_icon, link_path, counter, method = nil)
    class_name = current_page?(link_path) ? 'current' : nil

    if counter > 0
      notification_word = "<span class='notifier'>".html_safe + "" + counter.to_s + "" + "</span>".html_safe
    else
      notification_word = ""
    end

    if method.present?
      content_tag(:li, :class => class_name) do
        link_to link_path, :title => link_text, method: :delete do
          "<div class='visible-xs'><i class='fa fa-#{fa_icon}'></i>".html_safe + " " + link_text + "</div>".html_safe +
              "<div class='hidden-xs'><i class='fa  fa-lg fa-#{fa_icon}'></i></div>".html_safe + notification_word +
              "<div style='height: auto; float: none; clear:both;'></div>".html_safe
        end
      end
    else
      content_tag(:li, :class => class_name) do
        link_to link_path, :title => link_text do
          "<div class='visible-xs'><i class='fa fa-lg fa-#{fa_icon}'></i>".html_safe + " " + link_text + "</div>".html_safe +
              "<div class='hidden-xs'><i class='fa fa-lg fa-#{fa_icon}'></i></div>".html_safe + notification_word +
              "<div style='height: auto; float: none; clear:both;'></div>".html_safe
        end
      end

    end


  end

  def auto_link2(text, options)
    last = URI.extract(text).pop
    if last
      if text.index(last) + last.length + 4 == text.length
        return text
      else
        return auto_link(text,options)
      end
    else
      return auto_link(text,options)
    end
  end

end
