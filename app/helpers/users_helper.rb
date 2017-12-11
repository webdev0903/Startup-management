module UsersHelper

  def social_links(profile)
    return unless profile
    links = ['angellist', 'linkedin', 'twitter', 'facebook']
    social_links = ''
    links.each do |link|
      if profile[link].present?
        link_title = profile[link]
        link_title.slice! "https://"
        link_title.slice! "http://"
        link_title.slice! "www."
        link_title = truncate(link_title, :length => 25)

        actual_like = profile[link]
        actual_like = 'http://' + actual_like
        social_link = "<div class='userProfileLeftLink'>
          <a class='#{link}' href='#{actual_like}' target='blank' style='color:rgb(130,130,130)'></a>
        </div>"
        social_links << social_link
      end
    end
    social_links.html_safe
  end
  def websites(profile)
    return unless profile
    html = '<ul class="list-unstyled">'
    profile.website.each do |link|
      link_sanitized = link
      unless link[/^https?:\/\//]
        link_sanitized = "http://#{link}"
      end
      html << "<li><a rel='nofollow' href='#{link_sanitized}' target='blank'>#{link}</a></li>"    
    end
    html << '</ul>'
    html.html_safe
  end

  def connection_numbers(profile, connection)
    number = 0
    return number unless profile
    if profile[connection].present?
      number = profile[connection]
    end
    return number
  end

end