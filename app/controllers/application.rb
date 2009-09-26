# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'hpricot'
require 'open-uri'
require 'pp'

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionNotifiable  
  include SimpleCaptcha::ControllerHelpers  
  local_addresses.clear # always send email notifications instead of displaying the error
  
  helper :all # include all helpers, all the time
  helper_method :admin?, :admin_required


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
#  protect_from_forgery :secret => '66e4f871a737d1c50b0d702fd5c311c6'
  
  #before_filter :login_required
  
  #returns parent, sitter or admin
  before_filter :login_from_cookie  
  before_filter :direct_to_current_state
  before_filter :instantiate_controller_and_action_names
  # before_filter :adjust_format_for_iphone
  # before_filter :iphone_login_required
  
   
   def redirect_back_or(path)
     redirect_to :back
     rescue ActionController::RedirectBackError
     redirect_to path
   end

   def direct_to_current_state
     if logged_in?
       if current_user.is_a?Sitter   
         p = Sitter.find_by_id(current_user)
         case p.aasm_state
         when "new_account"
          redirect_to welcome_sitter_path(current_user)
         when "welcome"
          redirect_to your_skills_sitter_path(current_user)
         when "skills"   
          redirect_to your_families_sitter_path(current_user) 
         when "add_families"
          redirect_to your_friends_sitter_path(current_user)
         when "add_friends"   
          redirect_to invite_sitter_path(current_user)  
         when "complete"
           return
         end
       elsif current_user.is_a?Parent
          p = Parent.find_by_id(current_user)
          case p.aasm_state
          when "new_account"
           redirect_to welcome_parent_path(current_user)
          when "welcome"
           redirect_to your_children_parent_path(current_user) 
          when "add_children"
           redirect_to your_friends_parent_path(current_user) 
          when "add_friends"
           redirect_to your_sitters_parent_path(current_user)
          when "add_sitters"   
           redirect_to invite_parent_path(current_user)  
          when "complete"
            return
          end
       end
     else
       return
     end
   end
   
   
   def admin_required
     current_user && current_user.admin? ? true : access_denied
   end

   def find_user
     if @user = User.find(params[:user_id] || params[:id])
       @is_current_user = (@user && @user.eql?(current_user))
       unless logged_in? || @user.profile_public?
         flash.now[:error] = "This user's profile is not public. You'll need to create an account and log in to access it."
         redirect_to :controller => 'sessions', :action => 'new'        
       end
       return @user
     else
       flash.now[:error] = "Please log in."
       redirect_to :controller => 'sessions', :action => 'new'
       return false
     end
   end

   def require_current_user
     @user ||= User.find(params[:user_id] || params[:id] )
     unless current_user.admin? || (@user && (@user.eql?(current_user)))
       redirect_to :controller => 'sessions', :action => 'new' and return false
     end
     return @user
   end

   def popular_tags(limit = nil, order = ' tags.name ASC', type = nil)
     sql = "SELECT tags.id, tags.name, count(*) AS count 
       FROM taggings, tags 
       WHERE tags.id = taggings.tag_id "
     sql += " AND taggings.taggable_type = '#{type}'" unless type.nil?      
     sql += " GROUP BY tag_id"
     sql += " ORDER BY #{order}"
     sql += " LIMIT #{limit}" if limit
     Tag.find_by_sql(sql).sort{ |a,b| a.name.downcase <=> b.name.downcase}
   end


    def parent_required
      current_user && (current_user.is_a?Parent) ? true : access_denied
    end
  
    def sitter_required
      current_user && (current_user.is_a?Sitter) ? true : access_denied
    end
   
   
   def rounded(options={}, &content)
     options = {:class=>"box"}.merge(options)
     options[:class] = "box " << options[:class] if options[:class]!="box"

     str = '<div'
     options.collect {|key,val| str << " #{key}=\"#{val}\"" }
     str << '><div class="box_top"></div>'
     str << "\n"

     concat(str, content.binding)
     yield(content)
     concat('<br class="clear" /><div class="box_bottom"></div></div>', content.binding)
   end
   
     def instantiate_controller_and_action_names
         @previous_action = @current_action
         @previous_controller = @current_controller
         @current_action = action_name
         @current_controller = controller_name
     end

     # # Set iPhone format if request to iphone.trawlr.com
     #   def adjust_format_for_iphone
     #     request.format = :iphone if iphone_request?
     #   end
     # 
     #   # Force all iPhone users to login
     #   def iphone_login_required
     #     if iphone_request?
     #       redirect_to new_sessions_path unless logged_in?
     #     end
     #   end
     # 
     #   # Return true for requests to iphone.localhost.com
     #   def iphone_request?
     #     return (request.subdomains.first == "iphone" || params[:format] == "iphone")
     #   end
     # 
   
end
