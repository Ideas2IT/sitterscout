class HomeController < ApplicationController
 skip_before_filter :login_required
 skip_before_filter :direct_to_current_state, :only => [:tou]
 skip_before_filter :iphone_login_required
  layout 'home'
 
  def index
    
    if logged_in?
      if current_user.is_a?Parent
        redirect_to dashboard_parent_path(current_user)
      elsif current_user.is_a?Sitter
        redirect_to dashboard_sitter_path(current_user)
      end
    end
  end

  def sitter
  end

  def parent
  end

  def privacy
   render :layout => "no_search"
  end
  
  def tou
   render :layout => "no_search"
  end
  
  
end
