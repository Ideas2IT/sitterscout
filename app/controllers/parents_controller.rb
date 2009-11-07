class ParentsController < ApplicationController
  before_filter :login_required, :except => [:new, :create, :index, :activate]
  before_filter :parent_required, :except => [:new, :create, :index, :activate]
  skip_before_filter :direct_to_current_state, :only => [:search_sitters, :search_friends, :add_sitter, :add_friend, :add_children, :create, :send_invitations, :invite, :update_sitters, :update_children, :update_friends, :your_friends, :your_sitters, :update, :welcome, :update_my_children, :your_children, :insert_children, :confirm_email_sent]
  # auto_complete_for :profile, :full_name
  
  layout 'new_design'

  # GET /Parents
  # GET /Parents.xml
  def index
    if logged_in?
      case current_user.role.name
      when "sitter"
        redirect_to dashboard_sitter_path(current_user)  
      when "parent"
        redirect_to dashboard_parent_path(current_user)
      when "admin"
        redirect_to :action => 'index', :controller => 'admin'
      end
    end

    @metro_areas, @states = setup_locations_for_public_search
  end
  
  def update_sitters
    if request.post?
       p = Parent.find(current_user)
       p.aasm_state = "add_sitters"
       p.save
       redirect_to invite_parent_path(current_user)
     end
  end
  
  def sitters
    plist = Profile.sitters_you_may_know(current_user.profile).collect(&:id)
    #find(:all, :conditions => ["profile_public = ?", true]).collect(&:id)
    alist = current_user.accepted_friendships.collect(&:friend_id)
    ulist = current_user.pending_friendships.collect(&:friend_id)
    @sitters = []
    removed_people = RemovedPeople.find_users_removed_people_ids(current_user.id)
    
    
    sitter_ids = []
    plist.each do |p|
      unless current_user.id == p || alist.include?(p) || ulist.include?(p) || removed_people.include?(p)
        sitter_ids << p if sitter_ids.length < 5
      end
    end
    @sitters = Sitter.find(:all, :include => [:photo], :conditions => ["users.id in (?) ", sitter_ids])    
    
    
    @confirmed_sitters = []
    current_user.accepted_friendships.each do |f|
      if f.friend.is_a?Sitter
        @confirmed_sitters << f
      end
    end
    
#    @unconfirmed_sitters = []
#    current_user.pending_friendships.each do |f|
#      if f.friend.is_a?Sitter
#        @unconfirmed_sitters << f
#      end
#    end
    
    pending_friendship_sitter_ids = current_user.pending_friendships.select {|f| f.friend.is_a?Sitter}.collect {|f| f.friend.id}
    
    @unconfirmed_sitters = Sitter.find(:all, :include => [:photo], :conditions => ["users.id in (?) ", pending_friendship_sitter_ids])
  end

  def invite
    render :layout => "no_search"
  end

  def send_invitations
    p = Parent.find(current_user)
    unless p.aasm_state == "complete"
      p.aasm_state = "complete"
      p.save
      Notifications.deliver_parent_welcome(current_user)
    end
    @names = []
    @users = []
    if params[:commit]
      redirect_to welcome_screen_parent_path(current_user)
    else
      
      params[:invitation].keys.each do |invite|
          if User.find_by_email(params[:invitation][invite][:email_address])
            @users << User.find_by_email(params[:invitation][invite][:email_address])
          else
              unless params[:invitation][invite][:name].nil? || params[:invitation][invite][:name].blank?
                @names << params[:invitation][invite][:name]
                send_invitiations_emails(params[:invitation][invite][:name],params[:invitation][invite][:friendsitters],params[:invitation][invite][:email_address])
              end
          end
       end
     end
     
  end
  
  def welcome_screen
    
     p = Parent.find(current_user)
    unless p.aasm_state == "complete"
      p.aasm_state = "complete"
      p.save
      Notifications.deliver_parent_welcome(current_user)
    end
      #SitterMailer.deliver_send_welcome_email(current_user)
  end
  

  def new
    page_title = ""
    @parent = Parent.new( {:birthday => Date.parse((Time.now - 25.years).to_s) }.merge(params[:parent] || {}) )
    @inviter_id = params[:id]
    @inviter_code = params[:code]
    render :layout => "no_search"     
  end

  # GET /Parents/1/edit
  def edit
    @Parent = current_user
  end

  # POST /Parents
  # POST /Parents.xml
  def create
    
    
  if simple_captcha_valid?  
    
    @parent = Parent.new(params[:parent])
    @parent.birthday = 25.years.ago.to_date
    @parent.role = Role[:parent]  
    @parent.save!
    @parent.activate

    self.current_user = @parent
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      case self.current_user.role.name
      when "sitter"
        redirect_back_or_default(welcome_sitter_path(current_user))
      when "parent" 
        redirect_back_or_default(welcome_parent_path(current_user))
      when "admin"
        redirect_back_or_default(dashboard_user_path(current_user))
      end
      #flash[:notice] = "Thanks! You're now logged in."
    else
      redirect_back_or_default(home_page_path)
      flash[:notice] = "Uh oh. Something went wrong. Try again?"
      #flash.discard

    end
  else
    flash[:error] = "Please enter the text exactly as seen the box."
    #flash.discard
    render :action => 'new'
    
  end
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  
  def dashboard
    if session[:booked_sitters]
      @booked_sitters = session[:booked_sitters]
      session[:booked_sitters] = nil
    else
      @booked_sitters = []
    end
    @sitters = []
    current_user.accepted_friendships.each do |f|
      if f.friend.is_a?Sitter
        @sitters << f.friend
      end
    end

    @j = Job.find(:all, :conditions => ["parent_id = ? AND date_from > ?", current_user, Time.now])
   # @cancelledj = Job.find(:all, :conditions => ["status = ? AND parent_id = ?", "cancelled", current_user])
    render :action => 'schedule_sitter'
  end
  
  def check_availability
    
    dt_time = params["date_from_hour"] + ":" + params["date_from_min"] + " " + params["date_from_period"]
    dt = params[:date] + " " + dt_time
    
    date_to = params["date_to_hour"] + ":" + params["date_to_min"] + " " + params["date_to_period"]
    dt_to = params[:date] + " " + date_to
    
    
    week_day = dt.to_date.strftime("%A").downcase.pluralize
    
    if params["date_to_hour"].to_i <= 12 && params["date_to_period"] == "AM"
      shift = "Mornings"
    elsif params["date_from_hour"].to_i > 12 && params["date_from_period"] == "PM" && params["date_to_hour"].to_i >= 5 && params["date_to_period"] == "PM"
      shift = "Afternoons"
    elsif params["date_from_hour"].to_i > 5 && params["date_from_period"] == "PM"
      shift =  "Nights"
    else
      shift = "All Day"
    end
    
     alist = current_user.accepted_friendships.collect(&:friend_id)
      sitters = []
      alist.each do |p|
        if User.find(p).is_a?Sitter
          sitters << Sitter.find(p)
        end
      end
      
      available = []
      sitters.each do |s|
        unless s.profile.nil?
          if s.profile[week_day] == shift || s.profile[week_day] == "All Day"
            available << s.id
          end
        end
      end
      
      booked_sitters = []
      

   
      
      
      
      sitters.each do |sitter|
        unless sitter.profile.nil?
          j = Job.find(:all, :conditions => ["jobs.sitter_id = ? AND ((jobs.date_from between ? AND ?) OR (jobs.date_to between ? AND ?) OR (? between jobs.date_from AND jobs.date_to) OR (? between jobs.date_from AND jobs.date_to) OR (jobs.date_from = ?) OR (jobs.date_to = ?))", sitter.id, dt.to_datetime.to_s(:db), dt_to.to_datetime.to_s(:db), dt.to_datetime.to_s(:db), dt_to.to_datetime.to_s(:db), dt.to_datetime.to_s(:db), dt_to.to_datetime.to_s(:db), dt.to_datetime.to_s(:db), dt_to.to_datetime.to_s(:db)])
            unless j.blank?
              j.each do |r|
                temp_request = Request.find_by_job_id(r.id)
                unless temp_request.nil?
                  temp2 = RequestSitter.find_by_sql("SELECT state AS status FROM request_sitters WHERE request_id = '#{temp_request.id}'")[0]
                  if temp2.status == 'accepted'
                    booked_sitters << sitter
                 end
               end
             end
           end
        end
      end
            
      respond_to do |format|
         format.js do
           render :update do |page|
              sitters.each do |s|
                page.call "change_text_color", "sitter_#{s.id}", "#000000"
                page <<	"$('sitter_checkbox_#{s.id}').disabled=false;"

              end
              
              available.each do |a|
                page.call "change_text_color", "sitter_#{a}", "#87A933"
                page <<	"$('sitter_checkbox_#{a}').disabled=false;"
              end
              
              booked_sitters.each do |bs|
                page.call "change_text_color", "sitter_#{bs.id}", "#ACACAC"
                page <<	"$('sitter_checkbox_#{bs.id}').disabled=true;"

              end
              
           end
         end
      end
    
  end
  
  def remove_person
   rp = RemovedPeople.new(:user_id => current_user.id, :removed_user_id => params[:id])
  
   if rp.save
      respond_to do |format|
        format.html do
          redirect_to :back
        end
         format.js do
           render :update do |page|
              page.visual_effect :highlight, "person_#{params[:id]}_table", {:duration => 0.5, :startcolor => '#FF0000'} 
              page.visual_effect :fade, "person_#{params[:id]}_table", :duration => 0.5
              page.visual_effect :fade, "person_#{params[:id]}", :duration => 0.5
           end
         end
      end
    else
      redirect_to :back
    end
  end

  def cancel_job
    job = Job.find_by_parent_id_and_id(current_user.id, params[:id])
    job.status = "cancelled"
    job.save
    
    unless job.sitter_id.nil?
      Notifications.deliver_job_canceled(job.sitter, job.parent, job)
    else
      job.requests.first.sitters.each do |sitter|
        job.requests.first.request_sitters.each do |request_sitter|
          request_sitter.update_attribute(:state, "cancelled")
        end
        Notifications.deliver_job_canceled(sitter,job.parent,job)
      end
    end
    
    respond_to do |format|
      format.html do
        redirect_to dashboard_parent_path(current_user)
      end
       format.js do
         render :update do |page|
            page.replace_html "status_#{params[:id]}", "Cancelled"
            page.replace_html "job_#{params[:id]}", ''
         end
       end
    end
  end

  def my_children
    @children = current_user.children

    respond_to do |format|
      format.html
      format.js
    end
    
  end
  
  def insert_children
     @children = current_user.children
      respond_to do |format|
        format.html
        format.js do
          render :update do |page|
            if params[:children_shown].to_i == 0
              page.insert_html :after , "children_shown", :partial => 'child', :locals => {:t => "0"}
              
              (params[:number_of_children].to_i  - params[:children_shown].to_i).to_i.times do |t|
                if (params[:children_shown].to_i + t.to_i) > 0
                  page.insert_html :after , "child_" + (params[:children_shown].to_i + t.to_i - 1).to_s, :partial => 'child', :locals => {:t => (params[:children_shown].to_i + t.to_i).to_s}
                else
                  page.replace_html "child_" + (params[:children_shown].to_i + t.to_i).to_s, :partial => 'child', :locals => {:t => (params[:children_shown].to_i + t.to_i).to_s}
                end
              end
            
            elsif params[:number_of_children].to_i > params[:children_shown].to_i
              (params[:number_of_children].to_i - params[:children_shown].to_i).to_i.times do |t|
                if (params[:children_shown].to_i + t.to_i) > 0
                  page.insert_html :after , "child_" + (params[:children_shown].to_i + t.to_i - 1).to_s, :partial => 'child', :locals => {:t => (params[:children_shown].to_i + t.to_i).to_s}
                else
                  page.replace_html "child_" + (params[:children_shown].to_i + t.to_i).to_s, :partial => 'child', :locals => {:t => (params[:children_shown].to_i + t.to_i).to_s}
                end
              end  
            elsif params[:number_of_children].to_i < params[:children_shown].to_i
              (params[:children_shown].to_i - params[:number_of_children].to_i).to_i.times do |t|
                if params[:children_shown].to_i - t > 0
                  page.remove "child_" + (params[:children_shown].to_i - t.to_i-1).to_s
                else
                  page.replace_html 'child_0', ''
                end
              end 
            end
            page['children_shown'].value = params[:number_of_children]
          end
        end
      end

end

  def update_my_children
      @parent = current_user
      @children = current_user.children
      
       if params[:child]
          @children.each do |c|
            if !params[:child].include?(c)
             c.destroy
           end
          end
          
         params[:child].keys.each do |c| 
           @child = Child.find_or_create_by_name_and_parent_id(:name => params[:child][c][:name], :parent_id => current_user.id)
           age = params[:child][c]["age(2i)"]+ "/" + params[:child][c]["age(3i)"] + "/" + params[:child][c]["age(1i)"]
           @child.update_attributes(:name => params[:child][c][:name], :age => age)
           if @child.new_record?
             @parent.children << @child
           end
         end
       end
       flash[:notice] = "Your profile has been updated."
       redirect_to :action => "my_children"
  end
  


  # PUT /Parents/1
  # PUT /Parents/1.xml
  def update
    params[:user] ||= {}
    params[:profile] ||= {}
    @parent = current_user
  
    
    if params[:avatar]
    if @parent.photo
        @parent.photo.update_attributes(:uploaded_data => params[:avatar][:uploaded_data])
      else
        @parent.photo = Photo.create(:uploaded_data => params[:avatar][:uploaded_data])
      end
    end
    
    if @parent.profile.nil?
      @profile = Profile.new(params[:profile])
    else
      @profile = @parent.profile
    end
    if params[:profile_setup]
      @parent.aasm_state = "welcome"
    end  
    
    @profile.save
    @parent.profile = @profile
    
    if params[:user][:password]
      if params[:user][:password].nil? || params[:user][:password].blank? || params[:user][:password_confirmation].nil? || params[:user][:password_confirmation].blank? 
        flash[:error] = "Please enter the same password in both fields."
        redirect_to :back
        return
      elsif params[:user][:password] != params[:user][:password_confirmation]
        flash[:error] = "Passwords do not match confirmation."
        redirect_to :back
        return
      end
    end
    
    if @parent.update_attributes(params[:user]) && @profile.update_attributes(params[:profile])
       
        if params["login_update.x"]
           flash[:notice] = 'Your password has been changed.'
           redirect_to :back
        elsif params["update_avatar"]
          flash[:notice] = 'Your photo has been updated.'
          redirect_to :back
        elsif params[:update_profile]
          flash[:notice] = 'Profile updated.'
          redirect_to :back
        else
          redirect_to(your_children_parent_path(current_user))
        end
    else
      flash[:error] = "There was a problem saving your changes."
      redirect_to :back
    end 
  end

  
  

  # DELETE /Parents/1
  # DELETE /Parents/1.xml
  def destroy
    @parent = Parent.find_by_id(params[:id])
    @parent.destroy

    respond_to do |format|
      format.html { redirect_to(parents_url) }
      format.xml  { head :ok }
    end
  end
  
  
  def welcome
    @parent = current_user
    @user = @parent
    if @parent.profile.nil?
      @profile = Profile.new
    else
      @profile = @parent.profile
    end
    @metro_areas, @states = setup_locations_for(@parent)
  
    @avatar = Photo.new
    render :layout => "no_search"
  end
  
  def your_children
    render :layout => "no_search"
  end

  def your_friends
   @friends = Profile.parents_you_may_know(current_user.profile)   
    render :layout => "no_search"
  end


  def update_children
    if request.post?
      @parent = current_user

      if params[:child]
         params[:child].keys.each do |c|

           @child = Child.find_or_create_by_name_and_parent_id(:name => params[:child][c][:name], :parent_id => current_user.id)
           age = params[:child][c]["age(2i)"]+ "/" + params[:child][c]["age(3i)"] + "/" + params[:child][c]["age(1i)"]
           @child.update_attributes(:name => params[:child][c][:name], :age => age)
           if @child.new_record?
             @parent.children << @child
           end
         end
       end
      @parent.aasm_state = "add_children"
      @parent.save!
      redirect_to your_friends_parent_path(current_user)
    end
  end
  
  def update_friends
    if request.post?
      p = Parent.find(current_user)
      p.aasm_state = "add_friends"
      p.save!
      redirect_to your_sitters_parent_path(current_user)
    end
  end
  
  def friends
      plist = Profile.parents_you_may_know(current_user.profile).collect(&:id)
      #.find(:all, :conditions => ["profile_public = ?", true]).collect(&:id)
      alist = current_user.accepted_friendships.collect(&:friend_id)
      ulist = current_user.pending_friendships.collect(&:friend_id)
      dlist = current_user.denied_friendships.collect(&:friend_id)
      @parents = []
      
      removed_people = RemovedPeople.find_users_removed_people_ids(current_user.id)
    
      parent_ids = []
      plist.each do |p|
        unless current_user.id == p || alist.include?(p) || ulist.include?(p) || dlist.include?(p) || removed_people.include?(p)
          parent_ids << p if @parents.length < 5
        end
      end

      @parents = Parent.find(:all, :include => [:photo], :conditions => ["users.id in (?) ", parent_ids])    
      
      @confirmed_friends = []
      current_user.accepted_friendships.each do |f|
        if f.friend.is_a?Parent
          @confirmed_friends << f
        end
      end
     @unconfirmed_friends = []
#      current_user.pending_friendships.each do |f|
#        if f.friend.is_a?Parent
#          @unconfirmed_friends << f
#        end
#      end
      pending_friendship_parent_ids = current_user.pending_friendships.select {|f| f.friend.is_a?Parent}.collect {|f| f.friend.id}  
      @unconfirmed_friends = Parent.find(:all, :include => [:photo], :conditions => ["users.id in (?) ", pending_friendship_parent_ids])
      
  end
  
  def search_friends
     if params[:user]
          @search_friends = Profile.find_by_sql("select * from profiles where full_name LIKE '%#{params[:user][:search].to_s}%' OR first_name LIKE '%#{params[:user][:search].to_s}%' OR last_name LIKE '%#{params[:user][:search].to_s}%' AND not_searchable = 1")


          @ret = []
          @search_friends.concat Profile.tagged_with_and_parent(params[:user][:search])
          @search_friends.each do |p|
              if p.parent
                @ret << p unless p.not_searchable == false
              end
          end
    
    
    
    
    
      end
      
      respond_to do |format|
         format.html
         format.js do
           render :update do |page|
              if !@ret.empty?
                 page.replace_html 'friend_results', :partial => 'shared/search_people', :collection => @ret
                 page.insert_html  :top, 'friend_results', "<div style='font-family: \"Tahoma\"; font-size: 12pt;'>Search Results</div>"
                 page.show 'friend_results'
              else
                 page.replace_html 'friend_results', "No results were found."
                 page.show 'friend_results'
              end
            end
         end
      end
  end
  def search_sitters
    if params[:user]
        @search_friends = Profile.find_by_sql("select * from profiles where full_name LIKE '%#{params[:user][:search].to_s}%' OR first_name LIKE '%#{params[:user][:search].to_s}%' OR last_name LIKE '%#{params[:user][:search].to_s}%' AND not_searchable = 1")
        @search_friends.concat Profile.tagged_with_and_sitter(params[:user][:search])
        

        @ret = []
        @search_friends.concat Profile.tagged_with_and_parent(params[:user][:search])
        @search_friends.each do |p|
            if p.sitter
              @ret << p unless p.not_searchable == false
            end
        end
    end

    respond_to do |format|
       format.html
       format.js do
         render :update do |page|
            if !@ret.empty?
               page.replace_html 'sitter_results', :partial => 'shared/search_people', :collection => @ret
               page.insert_html  :top, 'sitter_results', "<div style='font-family: \"Tahoma\"; font-size: 12pt;'>Search Results</div>"
               page.show 'sitter_results'
            else
               page.replace_html 'sitter_results', "No results were found."
               page.show 'sitter_results'
            end
         end
       end
    end
  end
  def your_sitters
   @sitters = Profile.sitters_you_may_know(current_user.profile)   
    render :layout => "no_search"
  end
  
  def my_profile
    @parent = current_user
    @user = @parent
    if @parent.profile.nil?
      @profile = Profile.new
    else
      @profile = @parent.profile
    end
    @metro_areas, @states = setup_locations_for(@parent)
  end
  
    def create_friendship_with_inviter(user, options = {})
      unless options[:inviter_code].blank? or options[:inviter_id].blank?
        friend = Parent.find(options[:inviter_id])
        if friend && friend.valid_invite_code?(options[:inviter_code])
          accepted = FriendshipStatus[:accepted]
          @friendship = Friendship.new(:user_id => friend.id, :friend_id => user.id,:friendship_status => accepted, :initiator => true)
          reverse_friendship = Friendship.new(:user_id => user.id, :friend_id => friend.id, :friendship_status => accepted )
          @friendship.save
          reverse_friendship.save
        end
      end
    end
    
    def activate
      @parent = Parent.find_by_activation_code(params[:id])
      if @parent and @parent.activate
        self.current_user = @parent
        @parent.role = Role.find_by_name("parent")
        @parent.save
        redirect_to welcome_parent_path(@parent) #welcome_photo_user_path(@user)
        flash[:notice] = "Thanks for activating your account!" 
        #flash.discard
        return
      end
      flash[:error] = "Account activation failed. Your account may already be active. Try logging in or e-mail #{AppConfig.support_email} for help."
      #flash.discard
      redirect_to signup_path     
    end
    

    
    def schedule_sitter
      if session[:booked_sitters]
        @booked_sitters = session[:booked_sitters]
        session[:booked_sitters] = nil
      else
        @booked_sitters = []
      end
      alist = current_user.accepted_friendships.collect(&:friend_id)
      @sitters = []
      current_user.accepted_friendships.each do |f|
        if f.friend.is_a?Sitter
          @sitters << f.friend
        end
      end

      @j = Job.find(:all, :conditions => ["parent_id = ? AND date_from > ?",current_user, Time.now])
      #@cancelledj = Job.find(:all, :conditions => ["status = ? AND parent_id = ?", "cancelled", current_user])
    end
    def compose
      @people = []

      current_user.accepted_friendships.each do |af|
          @people << User.find(af.friend.id)
      end



      unless params[:id].to_i == current_user.id
        @user = User.find(params[:id])
      else 
        @user = ''
      end
    end
    
  	def inbox
  		@needs_ext = 1

  		@type = (params[:type]) ? params[:type] : 'received'

  	
  	end
    
    def profile
      
    end
    
    def sitter_search
    
    end


    def login_info
      @user = current_user
    end
    
    def view_profile
      @awaiting = params[:from]
      @user = Parent.find_by_id(params[:id])
      @profile = @user.profile
    end
    
    def view_sitter_profile
      @awaiting = params[:from]
      @user = Sitter.find_by_id(params[:id])
      @profile = @user.profile
    end
    
    def view_profile_search
      @user = Parent.find_by_id(params[:id])
      @profile = @user.profile
    end
    
    def view_sitter_profile_search
      @user = Sitter.find_by_id(params[:id])
      @profile = @user.profile
    end
    
    def view_profile_woc
      @user = Parent.find_by_id(params[:id])
      @profile = @user.profile
    end
    
    def view_sitter_profile_woc
      @user = Sitter.find_by_id(params[:id])
      @profile = @user.profile
    end
    
    def view_profile_sitter_ac 
      @user = Sitter.find_by_id(params[:id])
      @profile = @user.profile
    end
    
    def view_profile_friend_ac
      @user = Parent.find_by_id(params[:id])
      @profile = @user.profile
    end
    
    def view_connections
      @user = User.find(params[:id])
      @profile = @user.profile
      
      

      @families = []
      @sitters = []
      @user.accepted_friendships.each do |af|
        if af.friend.is_a?Parent
          @families << User.find(af.friend.id)
        else
          @sitters << User.find(af.friend.id)
        end
      end
      
    end
    
     def confirm_email_sent
         render :layout => 'none'
      end

      def hide_sitter_connection
        current = Friendship.find(:first, :conditions => ["user_id = ? AND friend_id = ?", current_user, params[:sitter_id]], :limit => 1)
        current.hide_connection = params[:hide_connection]
        current.save

         respond_to do |format|
             format.html
             format.js do
               render :update do |page|
                 page.visual_effect :highlight, "hide_#{params[:sitter_id]}_div", :startcolor => '#ffff99', :endcolor => '#fffffff'
               end
             end
          end
      end
      
      def auto_complete_for_profile_full_name_autocomplete
        @profiles = current_user.connections_search(params[:profile][:full_name_autocomplete].downcase)
        #Profile.find(:all, :conditions => ["full_name LIKE ?", '%' + params[:profile][:full_name_autocomplete].downcase + '%' ])
        render :partial => '/shared/fullnameautocomplete'
      end

    def connection_requests
      @unconfirmed_friends = current_user.pending_friendships_not_initiated_by_me
      
      end  
      
  
    protected

    def setup_metro_areas_for_cloud
      @metro_areas_for_cloud = MetroArea.find(:all, :conditions => "users_count > 0", :order => "users_count DESC", :limit => 100)
      @metro_areas_for_cloud = @metro_areas_for_cloud.sort_by{|m| m.name}
    end  


    def send_invitiations_emails(name, fors, email, msg=nil)
     case fors
     when "sitters"
       Notifications.deliver_sitter_invite(current_user, email, name, msg)
     when "friends"
       Notifications.deliver_friend_invite(current_user, email, name, msg)
      end
    end  


    def setup_locations_for(user)
      metro_areas = []
      if user.state
        metro_areas = @parent.state.metro_areas
      elsif user.country
        metro_areas = user.country.metro_areas
      end
      states = user.country.eql?(Country.get(:us)) ? State.find(:all) : []    
      return metro_areas, states
    end
    
    def setup_locations_for_public_search
      metro_areas = []
      states = State.find(:all)
      return metro_areas, states
    end

    def admin_or_current_user_required
      current_user && (current_user.admin? || @is_current_user) ? true : access_denied     
    end
  
   
    
end
