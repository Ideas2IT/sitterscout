# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def current_path
    if logged_in?
      if current_user.is_a?Parent
        return dashboard_parent_path(current_user)
      elsif current_user.is_a?Sitter
        return dashboard_sitter_path(current_user)
      end
    else
      return home_path
    end
  end
  # Request from an iPhone or iPod touch? (Mobile Safari user agent)
  def iphone_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end

  
end
