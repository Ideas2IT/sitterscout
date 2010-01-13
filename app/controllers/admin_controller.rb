class AdminController < ApplicationController
  before_filter :login_required
  before_filter :admin_required
  layout 'no_search'
  
  def index
    
    @total_sitters = Sitter.count()
    @total_parents = Parent.count()
    @approved_minor_sitters = Sitter.count(:include => [:consenting_parent],:conditions => ["users.minor = true and consenting_parents.approved = true"])
    @declined_minor_sitters = Sitter.count(:include => [:consenting_parent],:conditions => ["users.minor = true and (consenting_parents.approved = false) "])
    @minor_sitters_awaiting_response = Sitter.count(:include => [:consenting_parent],:conditions => ["users.minor = true and (consenting_parents.approved IS NULL)"])
    
    @total_sitters_month = Sitter.signup_month
    @total_parents_month = Parent.signup_month
    @sitting_request = Job.job_all.size
    
    user_id_coll = []
    friend_coll_month = []
    friend_coll = Friendship.friends_parent
    user_id_coll = friend_coll.collect(&:user_id)
    parent_sitter_request = User.find(:all, :conditions => ['users.id IN (?) AND users.type="Sitter"',user_id_coll])
    
    friend_coll.each do |fc|
      if fc.created_at.to_date > Date.today<<1 
        friend_coll_month << fc.user_id
      end
    end
    parent_sitter_request_month = User.find(:all, :conditions => ['users.id IN (?) AND users.type="Sitter"',friend_coll_month])
    
    job_filled = []
    job_unfilled = []
    job_all_month = []
    
    Job.job_all.each do |j|
      if !j.sitter_id.nil?
        job_filled << j.sitter_id
      else
        job_unfilled << j.parent_id
      end
      if j.created_at.to_date > Date.today<<1 
        job_all_month << j.parent_id 
      end
    end
    @sitting_request_filled = job_filled.size
    @sitting_reqeust_unfilled = job_unfilled.size
    @sitting_request_month = job_all_month.size
    @parent_sitter_connection = parent_sitter_request.size
    @parent_sitter_connection_month = parent_sitter_request_month.size
  end
  
  def compose
    
  end
  
  def send_message
    
    if params[:message][:user_type] == 'all'
      recipients = User.find(:all).collect(&:email).join(", ")
    elsif params[:message][:user_type] == 'sitters'
      recipients = Sitter.find(:all).collect(&:email).join(", ")
    else
      recipients = Parent.find_all.collect(&:email).join(", ")
    end
    
    Notifications.deliver_system_message(recipients, params[:message][:subject], params[:message][:body])
    
    flash[:notice] = "Your message has been sent."
    #flash.discard
    redirect_to :back
  end
  
  
  def export_users
    
     conditions = [];
      conditions << "users.id <> #{current_user.id}"

      unless params[:users][:email].blank?
        conditions << "users.email LIKE '%#{params[:users][:email]}%'"
      end

      unless params[:users][:first_name].blank?
        conditions << "profiles.first_name LIKE '%#{params[:profile][:first_name]}%'"
      end

      unless params[:users][:last_name].blank?
        conditions << "profiles.last_name LIKE '%#{params[:users][:last_name]}%'"
      end

      unless params[:users][:address_1].blank?
        conditions << "profiles.address_1 LIKE '%#{params[:users][:address_1]}%'"
      end

      unless params[:users][:address_2].blank?
        conditions << "profiles.address_2 LIKE '%#{params[:users][:address_2]}%'"
      end

      unless params[:users][:city].blank?
        conditions << "profiles.city LIKE '%#{params[:users][:city]}%'"
      end

      unless params[:users][:state_id].blank?
        conditions << "profiles.state_id = #{params[:users][:state_id]}"
      end
      
      unless params[:users][:zip].blank?
        conditions << "profiles.zipcode = #{params[:users][:zip]}"
      end

      unless conditions == 0
        conditions = conditions.join(' AND ')
      end


        preview_data  = ''
        filename = ''
        
        if params[:users][:user_type] == 'parents'
          @users = Parent.find(:all, :conditions => conditions, :include => 'profile')
          
          filename = "SitterScout_Parents_Export_#{Time.now.strftime("%m/%d/%Y_%I:%M_%p")}.csv"
          preview_data << "Name, Email, Zip, Last Login, Child Count \r"

          @users.each do |u|

            preview_data << "#{u.profile.full_name rescue ''}, #{u.email}, #{u.profile.zipcode rescue ''}, #{u.last_login_at.strftime("%m/%d/%Y %I:%M%p")}, #{u.children.length} \r"

          end
          
        elsif params[:users][:user_type] == 'sitters'
          @users = Sitter.find(:all, :conditions => conditions, :include => 'profile')
          
          filename = "SitterScout_Sitters_Export_#{Time.now.strftime("%m/%d/%Y_%I:%M_%p")}.csv"
          preview_data << "Name, Email, Zip, Last Login \r"

          @users.each do |u|

            preview_data << "#{u.profile.full_name rescue ''}, #{u.email}, #{u.profile.zipcode rescue ''}, #{u.last_login_at.strftime("%m/%d/%Y %I:%M%p")} \r"

          end
        else  
          
          @users = Parent.find(:all, :conditions => conditions, :include => 'profile')
          
          filename = "SitterScout_Users_Export_#{Time.now.strftime("%m/%d/%Y_%I:%M_%p")}.csv"
          preview_data << "Parents,,, \r"
          preview_data << "Name, Email, Zip, Last Login \r"

          @users.each do |u|

            preview_data << "#{u.profile.full_name rescue ''}, #{u.email}, #{u.profile.zipcode rescue ''}, #{u.last_login_at.strftime("%m/%d/%Y %I:%M%p")} \r"

          end
          
          preview_data << "\r\rSitters,,, \r"
          preview_data << "Name, Email, Zip, Last Login \r"
          
          @users = Sitter.find(:all, :conditions => conditions, :include => 'profile')
          
           @users.each do |u|

              preview_data << "#{u.profile.full_name rescue ''}, #{u.email}, #{u.profile.zipcode rescue ''}, #{u.last_login_at.strftime("%m/%d/%Y %I:%M%p")} \r"

           end
        end

        
    send_data preview_data, :filename => filename, :type => "application/octet-stream"
  end
  
  def search
   # @users_results = []
   # @users_results.paginate(:per_page => 50, :page => params[:page])
  end
  
  def search_users
    conditions = [];
    conditions << "users.id <> #{current_user.id}"
    
    unless params[:users][:email].blank?
      conditions << "users.email LIKE '%#{params[:users][:email]}%'"
    end
    
    unless params[:users][:first_name].blank?
      conditions << "profiles.first_name LIKE '%#{params[:users][:first_name]}%'"
    end

    unless params[:users][:last_name].blank?
      conditions << "profiles.last_name LIKE '%#{params[:users][:last_name]}%'"
    end

    unless params[:users][:address_1].blank?
      conditions << "profiles.address_1 LIKE '%#{params[:users][:address_1]}%'"
    end

    unless params[:users][:address_2].blank?
      conditions << "profiles.address_2 LIKE '%#{params[:users][:address_2]}%'"
    end

    unless params[:users][:city].blank?
      conditions << "profiles.city LIKE '%#{params[:users][:city]}%'"
    end

    unless params[:users][:state_id].blank?
      conditions << "profiles.state_id = #{params[:users][:state_id]}"
    end

    unless params[:users][:zip].blank?
      conditions << "profiles.zipcode = #{params[:users][:zip]}"
    end
    
    unless conditions == 0
      conditions = conditions.join(' AND ')
    end

    unless params[:users][:user_type].blank?
      if params[:users][:user_type] == 'parents'
        @users = Parent.find(:all, :conditions => conditions, :include => 'profile')
      elsif params[:users][:user_type] == 'sitters'
        @users = Sitter.find(:all, :conditions => conditions, :include => 'profile')
      else  
        @users = Parent.find(:all, :conditions => conditions, :include => 'profile')
        @users.concat(Sitter.find(:all, :conditions => conditions, :include => 'profile'))
        
      end
    end

          @items_per_page = 50
          @total_results = @users.length
          @total_pages = (@users.size.to_f / @items_per_page.to_f).ceil.to_i 
          if params[:page]
            @current_page = params[:page].to_i - 1
            slice_page = params[:page].to_i - 1
          else
            @current_page = 0
            slice_page = 0
          end
          @users_results = @users.slice((slice_page.to_i * @items_per_page), @items_per_page)
         respond_to do |format|
            format.html do
              render :template => '/admin/search'
            end
            format.js do
              render :update do |page|
                page.replace_html 'search_results', :partial => 'search_results', :object => @users_results
              end
            end
          end
      end

  
  def view_profile
    if User.find(params[:id]).is_a?Parent
      @user = Parent.find_by_id(params[:id])
    else
      @user = Sitter.find_by_id(params[:id])
    end
    
    @profile = @user.profile
    
  end
  
  def suspend_user
    @user = User.find(params[:id])
    @user.suspended = true
    if @user.save
      respond_to do |format|
        format.js do
          render :update do |page|
            page.call "change_background_color", "result_#{params[:id]}", "#33CCFF"
            page.replace_html "suspend_#{params[:id]}", :partial => 'change_suspended_link', :object => @user 
          end
        end
      end
    end  
    
  end
  
  def unsuspend_user
     @user = User.find(params[:id])
      @user.suspended = false
      if @user.save
        respond_to do |format|
          format.js do
            render :update do |page|
              page.call "change_background_color", "result_#{params[:id]}", "#F7F7F7"
              page.replace_html "suspend_#{params[:id]}", :partial => 'change_suspended_link', :object => @user 
            end
          end
        end
      end  
    
  end
  
  def delete_user
    user = User.find(params[:id])
    if user.destroy
      respond_to do |format|
        format.js do
          render :update do |page|
            page.visual_effect :highlight, "result_#{params[:id]}", {:duration => 0.5, :startcolor => '#FF0000'} 
            page.visual_effect :fade, "result_#{params[:id]}", :duration => 0.5            
          end
        end
      end
    end  
    
  end
  
  
  def update_user
    
  end
  
end
