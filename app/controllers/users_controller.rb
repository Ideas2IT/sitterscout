class UsersController < ApplicationController

  # 
  # #skip_before_filter :beta_login_required, :only => [:new, :new_parent, :create, :activate]
  # skip_before_filter :login_required, :only => [:new, :create]
  # 
  # 
  # def require_invitation
  #   redirect_to home_path and return false unless params[:inviter_id] && params[:inviter_code]
  #   redirect_to home_path and return false unless User.find(params[:inviter_id]).valid_invite_code?(params[:inviter_code])
  # end
  # 
  # 
  # def new
  #   @user = User.new( {:birthday => Date.parse((Time.now - 25.years).to_s) }.merge(params[:user] || {}) )
  # 
  # end
  # 
  # def new_sitter
  #   @user = User.new( {:birthday => Date.parse((Time.now - 25.years).to_s) }.merge(params[:user] || {}) )
  #   @inviter_id = params[:id]
  #   @inviter_code = params[:code]
  # end
  # 
  # def create
  #   @user = User.new(params[:user])
  #   @user.role = Role[:admin]
  #   @user.save!
  #   create_friendship_with_inviter(@user, params)
  #   flash[:notice] = "Thanks for signing up! You should receive an e-mail confirmation shortly at #{@user.email}"
  #   redirect_to signup_completed_user_path(@user)
  # rescue ActiveRecord::RecordInvalid
  #   render :action => 'new'
  # end
  # 
  # def destroy
  #   unless @user.admin?
  #     @user.destroy
  #     flash[:notice] = "The user was deleted."
  #   else
  #     flash[:error] = "You can't delete that user."
  #   end
  #   respond_to do |format|
  #     format.html { redirect_to users_url }
  #   end
  # end
  # 
  # def change_profile_photo
  #   @user = User.find(params[:id])
  #   @photo = Photo.find(params[:photo_id])
  #   @user.avatar = @photo
  #   if @user.save!
  #     flash[:notice] = "Your changes were saved."
  #     redirect_to user_photo_path(@user, @photo)
  #   end
  # rescue ActiveRecord::RecordInvalid
  #   render :action => 'edit'
  # end
  #   
  # 
  # 
  # 

  # 
  # def forgot_username  
  #   @user = User.find_by_email(params[:email])  
  #   return unless request.post?   
  #   if @user
  #     if @user.reset_password
  #       UserNotifier.deliver_forgot_username(@user)
  #       @user.save
  #       redirect_to login_url
  #       flash[:info] = "Your username was emailed to you."
  #     end
  #   else
  #     flash[:error] = "Sorry. We don't recognize that email address."
  #   end 
  # end
  # 
  # 
  # def assume
  #   user = User.find(params[:id])
  #   self.current_user = user
  #   redirect_to user_path(current_user)
  # end
  # 
  # def return_admin
  #   unless session[:admin_id].nil? or current_user.admin?
  #     admin = User.find(session[:admin_id])
  #     if admin.admin?
  #       self.current_user = admin
  #       redirect_to user_path(admin)
  #     end
  #   else
  #     redirect_to login_path
  #   end
  # end
  # 
  # def metro_area_update
  #   return unless request.xhr?
  #   if params[:state_id]
  #     metro_areas = MetroArea.find_all_by_state_id(params[:state_id], :order => "name")
  #     render :partial => 'shared/location_chooser', :locals => {:states => State.find(:all), :metro_areas => metro_areas, :selected_country => Country.get(:us).id, :selected_state => params[:state_id].to_i, :selected_metro_area => nil }
  #   else
  #     if params[:country_id].to_i.eql?(Country.get(:us).id)
  #       render :partial => 'shared/location_chooser', :locals => {:states => State.find(:all), :metro_areas => [], :selected_country => params[:country_id].to_i, :selected_state => params[:state_id].to_i, :selected_metro_area => nil }
  #     else
  #       metro_areas = MetroArea.find_all_by_country_id(params[:country_id], :order => "name")
  #       render :partial => 'shared/location_chooser', :locals => {:states => [], :metro_areas => metro_areas, :selected_country => params[:country_id].to_i, :selected_state => nil, :selected_metro_area => nil }
  #     end
  #   end      
  # end
  # 
  # def toggle_featured
  #   @user = User.find(params[:id])
  #   @user.toggle!(:featured_writer)
  #   redirect_to user_path(@user)
  # end
  # 
  # def toggle_moderator
  #   @user = User.find(params[:id])
  #   @user.role = @user.moderator? ? Role[:member] : Role[:moderator]
  #   @user.save!
  #   redirect_to user_path(@user)
  # end
  # 
  # 
  # def statistics
  #   if params[:date]
  #     date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i)
  #     @month = Time.parse(date.to_s)
  #   else
  #     @month = Time.today    
  #   end
  #   @posts = @user.posts.find(:all, 
  #     :conditions => ['? <= published_at AND published_at <= ?', @month.beginning_of_month, (@month.end_of_month + 1.day)])    
  #   
  #   @estimated_payment = @posts.sum do |p| 
  #     p.category.eql?(Category.get(:how_to)) ? 10 : 5
  #   end
  # end  
  # 
  # 
  # protected
  # 
  # def setup_metro_areas_for_cloud
  #   @metro_areas_for_cloud = MetroArea.find(:all, :conditions => "users_count > 0", :order => "users_count DESC", :limit => 100)
  #   @metro_areas_for_cloud = @metro_areas_for_cloud.sort_by{|m| m.name}
  # end  
  # 
  # def setup_locations_for(user)
  #   metro_areas = []
  #   if user.state
  #     metro_areas = @user.state.metro_areas
  #   elsif user.country
  #     metro_areas = user.country.metro_areas
  #   end
  #   states = user.country.eql?(Country.get(:us)) ? State.find(:all) : []    
  #   return metro_areas, states
  # end
  # 
  # def admin_or_current_user_required
  #   current_user && (current_user.admin? || @is_current_user) ? true : access_denied     
  # end
  

  
  def link_user_accounts
    
  if self.current_user.nil?
    set_facebook_session
    #register with fb
     if facebook_session and facebook_session.secured? and !request_is_facebook_tab?
 puts "sesssssssssion"
    fb_user=User.for(facebook_session.user.id, facebook_session)
    User.create_from_fb_connect(fb_user)
  else
    puts "no sesssssion"
    end
  else
    #connect accounts
    self.current_user.link_fb_connect(facebook_session.user.id) unless self.current_user.fb_user_id == facebook_session.user.id
  end
  redirect_to :back
end

  def top_bar_metro_area_update
    return unless request.xhr?
     if params[:topstate_id]
        metro_areas = MetroArea.find_all_by_state_id(params[:topstate_id], :order => "name")
        render :partial => 'shared/top_bar_location_chooser', :locals => {:states => State.find(:all), :selected_state => params[:topstate_id].to_i, :metro_areas => metro_areas }
     elsif params[:topmetro_area_id]
      metro_areas = MetroArea.find_all_by_state_id(MetroArea.find(params[:topmetro_area_id]).state_id, :order => "name")
      render :partial => 'shared/top_bar_location_chooser', :locals => {:states => State.find(:all), :selected_state => State.find(MetroArea.find(params[:topmetro_area_id]).state_id).id, :metro_areas => metro_areas, :selected_metro_area => params[:topmetro_area_id].to_i }      
     end
  end
  
  def metro_area_update
    return unless request.xhr?
     if params[:state_id]
        metro_areas = MetroArea.find_all_by_state_id(params[:state_id], :order => "name")
        render :partial => 'shared/location_chooser', :locals => {:states => State.find(:all), :selected_state => params[:state_id].to_i, :metro_areas => metro_areas }
     elsif params[:metro_area_id]
      metro_areas = MetroArea.find_all_by_state_id(MetroArea.find(params[:metro_area_id]).state_id, :order => "name")
      render :partial => 'shared/location_chooser', :locals => {:states => State.find(:all), :selected_state => State.find(MetroArea.find(params[:metro_area_id]).state_id).id, :metro_areas => metro_areas, :selected_metro_area => params[:metro_area_id].to_i }      
     end
 end
 
 def new_to_connect
   render :layout => 'lightbox'
 end
end
