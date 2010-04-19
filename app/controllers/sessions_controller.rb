# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  skip_before_filter :login_required, :except => :new
  skip_before_filter :direct_to_current_state
  layout 'home'
  
  
  def index
    redirect_to :action => "new"
  end  
  
  # render new.rhtml
  def new
    
    if logged_in?
      redirect_to user_path(current_user)
    end
    
  end
  
  def create_by_facebook_id  
    
    puts "#created_by_facebook_id=========================================="
    
    facebook_id=params[:fb_id_hidden]    
    self.current_user=User.already_connected?(facebook_id)  
    if self.current_user
      create
    else
      redirect_to :controller=>'home', :action=>'index', :logged=>'false'
    end
  end
  
  def create
    if !self.current_user      
      #      puts params[:fb_login]    
      #      puts params[:fb_id_hid]    
      if params[:fb_id_hid]       
        self.current_user = User.authenticate(params[:fb_login], params[:fb_password])
        if self.current_user
          #          puts "facccccccccccccccccc"
          #          puts self.current_user.facebook_id
          if self.current_user.facebook_id.to_i==0
            #            puts "this is woring====="
            self.current_user.facebook_id=params[:fb_id_hid]
            self.current_user.save!
          else
            #            cookies.delete :auth_token
            #            reset_session
            already_linked=true
            #           flash[:notice] = "This account is already linked to another facebook Account"
            #            redirect_to home_page_path
          end
        end
      else      
        self.current_user = User.authenticate(params[:login], params[:password])
      end    
    end
    
    if !already_linked
      
      if logged_in?
        
        if current_user.suspended?
          reset_session
          respond_to do |format|
            format.html {
              flash[:error] = "You're account has been suspended.  Please contact us to resolve this issue."
              #flash.discard
              redirect_to :controller => 'parents', :action => 'index'
            }
          end
        else
          if params[:remember_me] == "1"
            self.current_user.remember_me
            cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
          end
          
          if session[:accept_from_email]
            case self.current_user.role.name
              when "sitter"
              redirect_to connection_requests_sitter_path(current_user)
              # flash[:notice] = "Thanks! You're now logged in."
              when "parent" 
              redirect_to connection_requests_parent_path(current_user)
              session[:booked_sitters] = '' #used in dashboard
              # flash[:notice] = "Thanks! You're now logged in."
            end
            session[:accept_from_email] = '';
          elsif !session[:last_page]
            case self.current_user.role.name
              when "sitter"
              redirect_back_or_default(dashboard_sitter_path(current_user))
              # flash[:notice] = "Thanks! You're now logged in."
              when "parent" 
              redirect_back_or_default(dashboard_parent_path(current_user))
              session[:booked_sitters] = '' #used in dashboard
              # flash[:notice] = "Thanks! You're now logged in."
              when "admin"
              redirect_back_or_default(:controller => 'admin', :action => 'index')
              #  flash[:notice] = "Thanks! You're now logged in."
            end
          else
            redirect_to(session[:last_page].to_s)
          end
        end
      else
        respond_to do |format|
          format.html {
            redirect_to :back
            flash[:error] = "We couldn’t log you in with the user name and password you entered. Would you like to try again?"   
            ##flash.discard
          }
        end
      end
    else
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      #flash.discard
      flash[:error] = "This account is already linked to another facebook Account!"
      redirect_to home_page_path
    end
  end
  
  def forgot_password  
    @user = User.find_by_email(params[:email])  
    return unless request.post?   
    if @user
      if @user.reset_password
        Notifications.deliver_reset_password(@user)
        @user.save
        
        flash[:notice] = "Your password has been reset and emailed to you."
        flash.discard
        
        #        redirect_to(home_page_path)
        
      end
    else
      flash[:error] = "Sorry. We don't recognize that email address."
      flash.discard
    end 
  end
  
  def forgot_password_popup 
    @user = User.find_by_email(params[:email])  
    return unless request.post?   
    if @user
      if @user.reset_password
        Notifications.deliver_reset_password(@user)
        @user.save
        
        flash[:notice] = "Your password has been reset and emailed to you."
        flash.discard
        
        redirect_to(home_page_path)
        
      end
    else
      flash[:error] = "Sorry. We don't recognize that email address."
      flash.discard
    end 
  end
  
  
  def destroy    
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You've been logged out. Hope you come back soon!"
    #flash.discard
    redirect_to home_page_path
  end
  
  
end
