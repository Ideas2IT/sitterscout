class SittersController < ApplicationController
  before_filter :login_required, :except => [:new, :create, :index, :activate, :consent_sent]
  before_filter :sitter_required, :except => [:new, :create, :index, :activate, :consent_sent]
  skip_before_filter :direct_to_current_state, :only => [:update_families, :welcome, :your_friends, :your_families, :search_families, :search_friends,:search_sitters, :add_sitter, :add_friend, :create, :send_invitations, :invite, :update_sitters, :update_friends,:update_families, :your_friends, :your_families, :add_family, :your_sitters, :your_skills, :create_skills, :update, :welcome, :confirm_email_sent]
   
 # auto_complete_for :profile, :full_name
  layout 'new_design'
  
  def index
    #render :layout => 'parent'
    if logged_in?
       case current_user.role.name
       when "sitter"
         redirect_to dashboard_sitter_path(current_user)  
       when "parent"
         redirect_to dashboard_parent_path(current_user)
       when "admin"
         redirect_to dashboard_admin_path(current_user)      
       end
     end
  end
  
  def consent_sent
  end
  
  def new
    render :layout => 'no_search'
  end
  
  
  def create

  if simple_captcha_valid?  
  #    
    @sitter = Sitter.new(params[:sitter])
    @sitter.role = Role[:sitter]  
    
    if @sitter.underage? && params[:parent_email].nil?
      @sitter.errors.add(:birthday, "Underage") 
    end
    
    if params[:parents_email] == params[:sitter][:email]
      flash[:error] = "Please enter a valid parent email address."
      redirect_to(new_sitter_path)
      return
      #      @sitter.errors.add(:email, "Please enter a valid parent email address.")
    end
    
    @sitter.save!
    
    if @sitter.underage?
      ActiveRecord::Base.transaction do 
         @cs = ConsentingParent.new
         @cs.name = params[:parents_name]
         @cs.email = params[:parents_email]
         @cs.underaged_sitter = @sitter
         @sitter.profile_public = false
         @sitter.minor = true
         @sitter.profile = Profile.create(:last_name => params[:minor_last_name], :first_name => params[:minor_first_name],:not_searchable => true)
         @cs.save && @sitter.save
      end
       Notifications.deliver_parent_consent_request(@cs, @sitter)
       redirect_to(consent_sent_sitter_path(@sitter))
       return    
     else
      @sitter.save!
      @sitter.activate  
      self.current_user = @sitter
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
        redirect_to(new_sitter_path)
        flash[:notice] = "Uh oh. Something went wrong. Try again?"
        ##flash.discard

      end
    end
   else
      flash[:error] = "Please enter the text exactly as seen the box."
      ##flash.discard
      render :action => 'new'
      
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def view_connections
    #need to convert to friends of parent clicked
    @families = Parent.find(:all)
    @sitters = Sitter.find(:all)
    render :layout => 'bare'
  end

  def view_parent_profile 
#   @user = Parent.find_by_id(params[:id])
    @user = Parent.find(params[:id])
    @profile = @user.profile
  end

    
  def view_friend_profile
#    @user = Sitter.find_by_id(params[:id])
     @user = Sitter.find(params[:id])
     @profile = @user.profile
  end
    
  def view_parent_profile_search
#    @user = Parent.find_by_id(params[:id])
     @user = Parent.find(params[:id])
     @profile = @user.profile
  end
  
  def view_friend_profile_search
#    @user = Sitter.find_by_id(params[:id])
     @user = Sitter.find(params[:id])
     @profile = @user.profile
  end
  def view_friend_profile_woc
    @awaitingconf=params[:from]
#   @user = Sitter.find_by_id(params[:id])
    @user = Sitter.find(params[:id])
    @profile = @user.profile
  end
  def view_parent_profile_woc
    @awaitingconf=params[:from]
#   @user = Parent.find_by_id(params[:id])
   @user = Parent.find(params[:id])
    @profile = @user.profile 
  end
  
  def view_profile_friend_ac
#    @user = Sitter.find_by_id(params[:id])
    @user = Sitter.find(params[:id])
    @profile = @user.profile
  end
  
  def view_profile_family_ac
#    @user = Parent.find_by_id(params[:id])
    @user = Parent.find(params[:id])
    @profile = @user.profile 
  end
  
  
 
  def add_family
    if request.post?
      Friendship.request(current_user, Parent.find_by_id(params[:id]))
      flash.now[:notice] = "Invitation sent."
      ##flash.discard
    end
    
    render :layout => 'lightbox'
  end
  
   def add_friend
      if request.post?
        Friendship.request(current_user, Sitter.find(params[:friend_id]))
        flash[:notice] = "Invitation sent."
        ##flash.discard
      end
              
      render :layout => 'lightbox'
     
    end

  def update_families
    @user = current_user
    @user.aasm_state = "add_families"
    @user.save!
    redirect_to your_friends_sitter_path(current_user)
  end
  
  
  def login_info
    @user = current_user
  end

  def update
    params[:user] ||= {}
    params[:profile] ||= {}

    @sitter = current_user

    if params[:avatar]
    if @sitter.photo
        @sitter.photo.update_attributes(:uploaded_data => params[:avatar][:uploaded_data])
      else
        @sitter.photo = Photo.create(:uploaded_data => params[:avatar][:uploaded_data])
      end
    end

    if @sitter.profile.nil?
      @profile = Profile.create(params[:profile])
    else
      @profile = @sitter.profile
    end
    if params[:profile_setup]  
      @sitter.aasm_state = "welcome"
    end  
    if !@profile.save
    	#flash[:error] = "There was a problem saving your profile."
    	flash[:error] = @profile.errors.full_messages.join(", ")
    	##flash.discard
	    redirect_to :back
	    return
    end
    
    @sitter.profile = @profile
    
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
    if @sitter.update_attributes(params[:user]) && @profile.update_attributes(params[:profile])
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
          redirect_to(your_skills_sitter_path(current_user))
        end
    else
        flash[:error] = "There was a problem saving your changes."
        redirect_to :back
    end  
  end

  def your_skills
    @user = current_user
    @profile = current_user.profile
    @skill = current_user.skill
    render :layout => "no_search"
  end
  def update_skills
      if current_user.skill.nil?
        current_user.skill = Skill.create(params[:skill])

      else
        current_user.skill.update_attributes(params[:skill])
      end
      current_user.profile.update_attributes(params[:profile])

      current_user.update_attributes(params[:user])

      current_user.save
      flash[:notice] = 'Your Skills have been updated.'
      respond_to do |format|
        format.html { redirect_to skills_sitter_path(current_user)}
      end
  end

  def create_skills
    if current_user.skill.nil?
      current_user.skill = Skill.create(params[:skill])
      
    else
      current_user.skill.update_attributes(params[:skill])
    end
    current_user.profile.update_attributes(params[:profile])
    
    current_user.update_attributes(params[:user])
    
    current_user.aasm_state = "skills"

    current_user.save
    
    respond_to do |format|
      format.html { redirect_to your_families_sitter_path(current_user)}
    end
  end
  
  def dashboard
    redirect_to :action => :your_requests
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
  
  def your_requests
    if current_user.underage?
      unless current_user.consenting_parent.nil?
        if current_user.consenting_parent.approved
          @parents = []
          current_user.accepted_friendships.each do |f|
            @parents << f.friend unless f.friend.is_a?Sitter
          end         
          @jtemp = RequestSitter.find(:all, :conditions => ["sitter_id = ?", current_user])
          @j = []
          for rs in @jtemp
            if rs.request.job.date_from > Time.now
              @j << rs
            end
          end
            
          @accepted = RequestSitter.find(:all, :conditions => ["state = ? AND sitter_id = ?", "accepted", current_user])
          @cancelledj = RequestSitter.find(:all, :conditions => ["state = ? AND sitter_id = ?", "cancelled", current_user])
        else
          self.current_user.forget_me if logged_in?
          cookies.delete :auth_token
          reset_session
          flash[:error] = "Please Try again when you have approval from a consenting Parent."
          #flash.discard
          redirect_to home_page_path
        end#consent approved
      else
        self.current_user.forget_me if logged_in?
        cookies.delete :auth_token
        reset_session
        flash[:error] = "Please Try again when you have approval from a consenting Parent."
        #flash.discard
        redirect_to home_page_path
      end#consenting parent not nil
    else
      @parents = []
      
      current_user.accepted_friendships.each do |f|
        @parents << f.friend unless f.friend.is_a?Sitter
      end
      
      @jtemp = RequestSitter.find(:all, :conditions => ["sitter_id = ?", current_user])
      @j = []
      for rs in @jtemp
        unless rs.request.job.nil?
          if rs.request.job.date_from > Time.now
            @j << rs
          end
        end
      end
      @accepted = RequestSitter.find(:all, :conditions => ["state = ? AND sitter_id = ?", "accepted", current_user])
      @cancelledj = RequestSitter.find(:all, :conditions => ["state = ? AND sitter_id = ?", "cancelled", current_user])
    end #underage
  end
  


  def your_families
    @families = Profile.parents_you_may_know(current_user.profile,30)
    render :layout => "no_search"
  end
  
  def your_friends
    
    @friends = Profile.sitters_you_may_know(current_user.profile,30)
    render :layout=> "no_search"
    
#    plist = Profile.sitters_you_may_know(current_user.profile).collect(&:id)
#    @friends = []
#     plist.each do |p|
#        unless current_user.id == p 
#          @friends << Sitter.find(p)
#        end
#      end
#    render :layout => "no_search"
    
  end
  
  def update_friends
    current_user.aasm_state = "add_friends"
    current_user.save
    redirect_to invite_sitter_path(current_user)
  end
  
  def friends
      plist = Profile.sitters_you_may_know(current_user.profile).collect(&:id)
      #.find(:all, :conditions => ["profile_public = ?", true]).collect(&:id)
      alist = current_user.accepted_friendships.collect(&:friend_id)
      ulist = current_user.pending_friendships.collect(&:friend_id)
      dlist = current_user.denied_friendships.collect(&:friend_id)
      
      @sitters = []
      
      removed_people = RemovedPeople.find_users_removed_people_ids(current_user.id)
      
      sitter_ids=[]
      plist.each do |p|
        unless current_user.id == p || alist.include?(p) || ulist.include?(p) || dlist.include?(p) || removed_people.include?(p)
          sitter_ids << p if sitter_ids.length < 5
        end
      end
      
      @sitters = Sitter.find(:all, :include => [:photo], :conditions => ["users.id in (?) ", sitter_ids])    
          
      @confirmed_friends = []
#        current_user.accepted_friendships.each do |f|
#          if f.friend.is_a?Sitter
#            @confirmed_friends << f
#          end
#        end
        
     accepted_friendship_sitter_ids = current_user.accepted_friendships.select {|f| f.friend.is_a?Sitter}.collect {|f| f.friend.id}  
     @confirmed_friends = Sitter.find(:all, :include => [:photo], :conditions => ["users.id in (?) ", accepted_friendship_sitter_ids])   
      
      @unconfirmed_friends = []
#      current_user.pending_friendships.each do |f|
#        if f.friend.is_a?Sitter
#          @unconfirmed_friends << f
#        end
#    end
    
     pending_friendship_sitter_ids = current_user.pending_friendships.select {|f| f.friend.is_a?Sitter}.collect {|f| f.friend.id}  
     @unconfirmed_friends = Sitter.find(:all, :include => [:photo], :conditions => ["users.id in (?) ", pending_friendship_sitter_ids])
  end
  
  def families
    plist = Profile.parents_you_may_know(current_user.profile).collect(&:id) #just return the 30 values in the distance order
    #.find(:all, :conditions => ["profile_public = ?", true]).collect(&:id)
    alist = current_user.accepted_friendships.collect(&:friend_id) # just return who are accepted in the friend ship
    ulist = current_user.pending_friendships.collect(&:friend_id) # just return who are pending friends
    dlist = current_user.denied_friendships.collect(&:friend_id) # just return who are denied friends
    
    @parents = []
    
    parent_ids = []
    
    removed_people = RemovedPeople.find_users_removed_people_ids(current_user.id)
    
    plist.each do |p|
      unless current_user.id == p || alist.include?(p) || ulist.include?(p) || dlist.include?(p) || removed_people.include?(p)
        parent_ids << p if parent_ids.length < 5
      end
    end
  
    @parents = Parent.find(:all, :include => [:photo], :conditions => ["users.id in (?) ", parent_ids])
  
    @confirmed_friends = []
#    current_user.accepted_friendships.each do |f|
#      if f.friend.is_a?Parent
#        @confirmed_friends << f
#      end
#    end
    
    accepted_friendship_parent_ids = current_user.accepted_friendships.select {|f| f.friend.is_a?Parent}.collect {|f| f.friend.id}  
    @confirmed_friends = Parent.find(:all, :include => [:photo], :conditions => ["users.id in (?) ", accepted_friendship_parent_ids])
    
    @unconfirmed_friends = []
#    current_user.pending_friendships.each do |f|
#      if f.friend.is_a?Parent
#        @unconfirmed_friends << f
#      end
#    end  
    
     pending_friendship_parent_ids = current_user.pending_friendships.select {|f| f.friend.is_a?Parent}.collect {|f| f.friend.id}  
     @unconfirmed_friends = Parent.find(:all, :include => [:photo], :conditions => ["users.id in (?) ", pending_friendship_parent_ids])
  
  end
  
  def search_friends
     if params[:user]
#       @search_friends = Profile.find_by_sql("select * from profiles where full_name LIKE '%#{params[:user][:search].to_s}%' OR first_name LIKE '%#{params[:user][:search].to_s}%' OR last_name LIKE '%#{params[:user][:search].to_s}%' AND not_searchable = 1")
     
     @search_friends = Profile.find(:all, :include => [:sitter],:conditions => ("full_name LIKE  '%#{params[:user][:search].to_s}%' OR first_name LIKE '%#{params[:user][:search].to_s}%' OR last_name LIKE  '%#{params[:user][:search].to_s}%' AND not_searchable = 1"))

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
  
  def search_families
    if params[:user]
#      @search_friends = Profile.find_by_sql("select * from profiles where full_name LIKE '%#{params[:user][:search].to_s}%' OR first_name LIKE '%#{params[:user][:search].to_s}%' OR last_name LIKE '%#{params[:user][:search].to_s}%' AND not_searchable = 1")
      
      @search_friends = Profile.find(:all, :include => [:parent],:conditions => ("full_name LIKE  '%#{params[:user][:search].to_s}%' OR first_name LIKE '%#{params[:user][:search].to_s}%' OR last_name LIKE  '%#{params[:user][:search].to_s}%' AND not_searchable = 1"))
      
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
              page.replace_html 'families_results', :partial => 'shared/search_people', :collection => @ret
              page.insert_html  :top, 'families_results', "<div style='font-family: \"Tahoma\"; font-size: 12pt;'>Search Results</div>"
              page.show 'families_results'
           else
              page.replace_html 'families_results', "No results were found."
              page.show 'families_results'
           end
         end
       end
    end
  end
  

  def auto_complete_for_profile_full_name_autocomplete
    @profiles = Profile.find(:all, :conditions => ["full_name LIKE ?", '%' + params[:profile][:full_name_autocomplete].downcase + '%' ])
    render :partial => '/shared/fullnameautocomplete'
  end
  
  
  def connection_requests
    @unconfirmed_friends = current_user.pending_friendships_not_initiated_by_me
    
    end



  def welcome
      @sitter = current_user
      @user = @sitter
      @profile = @sitter.profile || Profile.new
      @metro_areas, @states = setup_locations_for(@sitter)
 
      @avatar = Photo.new
      render :layout => "no_search"
    end
    
    	def inbox
    		@needs_ext = 1

    		@type = (params[:type]) ? params[:type] : 'received'

    		page_number = (params[:start].to_i / 25) + 1 || 1
    		respond_to do |wants|
    			wants.html
    			wants.js {
    				msg_type = params[:type]||"received"
    				msg_search = params[:search]||""

    				case params[:sort]
    					when "nickname"
    						sort = "nickname"
    					when "status"
    						sort = "messages.status"
    					when "subject"
    						sort = "messages.subject"
    					else
    						sort = "messages.created_at"
    				end

    				case params[:dir]
    					when "ASC"
    						dir = "ASC"
    					else
    						dir = "DESC"
    				end

    				return_data = {}
    				case msg_type
            	when "received"
      					messages = current_user.received_messages.find(:all)## ,
      					#            :include => :sender,
      					#            :conditions => ["(subject like ? OR body LIKE ?) AND (users.deleted_at is null OR users.deleted_at > ?)", '%' + msg_search + '%', '%' + msg_search + '%', Time.now],
      					#            :order => sort + " " + dir,
      					#            :page => {
      					#              :size => 25, 
      					#              :current => page_number
      					#            }
      				#	)
      					return_data[:messages] = messages.collect{|m| {
      						:id => m.id,
      						:nickname => m.sender.profile.full_name,
      						:subject => truncate(m.subject,15),
      						:created_at => m.created_at.strftime('%m/%d/%Y'),
      						:status => m.status,
      						:type => "received"
      					}}
      				else
      					messages = current_user.sent_messages.find(:all,
      						:include => :recipient,
      						:conditions => ["(subject like ? OR body LIKE ?) AND (users.deleted_at is null OR users.deleted_at > ?)", '%' + msg_search + '%', '%' + msg_search + '%',Time.now],
      						:order => sort + " " + dir,
      						:page => {
      							:size => 25, 
      							:current => page_number
      						}
      					)
      					return_data[:messages] = messages.collect{|m| {
      						:id => m.id,
      						:nickname => m.recipient.profile.full_name,
      						:subject => truncate(m.subject,15),
      						:created_at => m.created_at.strftime('%m/%d/%Y'),
      						:status => m.status,
      						:type => "sent"
      					}}
      				end

    				return_data[:total] = messages.size
    				return_data[:unreadTotal] = current_user.unread_received_messages.size
    				render :json => return_data.to_json
    			}
    		end
    	end

    
  def my_profile
      @sitter = Sitter.find_by_id(params[:id])
      @user = @sitter
      if @sitter.profile.nil?
        @profile = Profile.new
      else
        @profile = @sitter.profile
      end
      @metro_areas, @states = setup_locations_for(@sitter)
    end
  
  def create_friendship_with_inviter(user, options = {})
      unless options[:inviter_code].blank? or options[:inviter_id].blank?
        friend = Sitter.find(options[:inviter_id])
        if friend && friend.valid_invite_code?(options[:inviter_code])
          accepted = FriendshipStatus[:accepted]
          @friendship = Friendship.new(:user_id => friend.id, :friend_id => user.id,:friendship_status => accepted, :initiator => true)
          reverse_friendship = Friendship.new(:user_id => user.id, :friend_id => friend.id, :friendship_status => accepted )
          @friendship.save
          reverse_friendship.save
        end
      end
    end
    
    def my_profile_manage
      
    end
    
    def delete_profile
       
      if params[:profdel][:deactive] 
        @user = User.find(params[:id])
        @user.active = true
        if @user.save 
          flash[:notice] = 'Profile updated successfully.'
          redirect_to :back
        else
          flash[:error] = "There was a problem saving your changes."
          redirect_to :back
        end
        
      elsif params[:profdel][:reactive]
          @user = User.find(params[:id])
          @user.active= false
           if @user.save 
              flash[:notice] = 'Profile updated successfully.'
              redirect_to :back
           else
             flash[:error] = "There was a problem saving your changes."
             redirect_to :back
          end
      end 
#      if params[:profdel][:manage] == "deactive"
#          @user = User.find(params[:id])
#          @user.active = true
#          if @user.save 
#            flash[:notice] = 'Profile updated successfully.'
#            redirect_to :back
#          else
#            flash[:error] = "There was a problem saving your changes."
#            redirect_to :back
#          end
#      elsif params[:profdel][:manage] == "cancel"
#          user = User.find(current_user)
#          if user.destroy
#            respond_to do |format|
#              format.html { redirect_to("/") }
#              format.xml  { head :ok }
#            end
#        end
#      elsif params[:profdel][:manage] == "reactive"
#        @user = User.find(params[:id])
#        @user.active= false
#        if @user.save 
#          flash[:notice] = 'Profile updated successfully.'
#          redirect_to :back
#          else
#            flash[:error] = "There was a problem saving your changes."
#            redirect_to :back
#         end
#      end     
      
    end
    
  def activate
      @sitter = Sitter.find_by_activation_code(params[:id])
      if @sitter and @sitter.activate
        self.current_user = @sitter
        @sitter.role = Role.find_by_name("sitter")
        @sitter.save
        redirect_to welcome_sitter_path(@sitter) #welcome_photo_user_path(@user)
        flash[:notice] = "Thanks for activating your account!" 
        return
      end
      flash[:error] = "Account activation failed. Your account may already be active. Try logging in or e-mail #{AppConfig.support_email} for help."
      redirect_to sitter_signup_path     
    end
  
  def availability
      @profile = current_user.profile
  end
  
  def accept_job
    acceptjob(params[:id])
  end

  def skills
    @user = current_user
    @profile = current_user.profile
     @skill = @user.skill
  end
  
  def decline_job
    declinejob(params[:id])
  end
  
  def accept_job_from_email
    acceptjob(params[:id])
  end
  
  def invite
    render :layout => "no_search"
  end
  
  def decline_job_from_email
    declinejob(params[:id])
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
    
    
  def send_invitations
    
      p = Sitter.find(current_user)
      unless p.aasm_state == "complete"
        p.aasm_state = "complete"
        p.save
        Notifications.deliver_sitter_welcome(current_user, params[:invitations_box])
      end

      @names = []
      @users = []
      
      if params[:commit]
        redirect_to welcome_screen_sitter_path(current_user)
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
      #SitterMailer.deliver_send_welcome_email(current_user)
      
  end
  
  def welcome_screen
    
     p = Sitter.find(current_user)
      unless p.aasm_state == "complete"
        p.aasm_state = "complete"
        p.save
        Notifications.deliver_sitter_welcome(current_user)
      end
        
      #SitterMailer.deliver_send_welcome_email(current_user)
  end
    
protected

  def acceptjob(id)
    
    unless Job.find(id).status == 'accepted'
      rs = RequestSitter.find(:first, :include => ["request"], :conditions => ["request_sitters.sitter_id = ? AND requests.job_id = ?", current_user, id])
      rs.request.job.status = "accepted"
      #To update the job status
      unless rs.request.job.nil?
        job = rs.request.job
        job.status = "accepted"
        job.save
      end
      
      rs.state = "accepted"
      rs.save
      
      j = Job.find(id)
      j.sitter_id = current_user.id
      j.save
      
      rs.request.sitters.each do |email|
        Notifications.deliver_job_filled(email, Job.find(rs.request.job.id)) unless email == current_user
        RequestSitter.find(:all, :conditions => ["request_id = ? AND sitter_id <> ?", rs.request.id, current_user.id]).each do |req|
          req.state = "filled"
          req.save
        end
        
      end
      Notifications.deliver_job_accepted(current_user, Parent.find(rs.request.job.parent_id), Job.find(rs.request.job.id))
    end
    redirect_back_or_default(dashboard_sitter_path(current_user))
  end
  
  def declinejob(id)
    rs = RequestSitter.find(:first, :include => ["request"], :conditions => ["request_sitters.sitter_id = ? AND requests.job_id = ?", current_user, id])
    Notifications.deliver_job_declined(current_user, Parent.find(rs.request.job.parent_id), Job.find(rs.request.job.id)) unless rs.state == "declined"
    rs.state = "declined"
    rs.save
    redirect_back_or_default(dashboard_sitter_path(current_user))
  end


  def send_invitiations_emails(name, fors, email, msg=nil)
   case fors
   when "sitters"
     Notifications.deliver_sitter_invite(current_user, email, name, msg)
   when "friends"
     Notifications.deliver_friend_invite(current_user, email, name, msg)
   end
   
  end  


  def setup_metro_areas_for_cloud
      @metro_areas_for_cloud = MetroArea.find(:all, :conditions => "users_count > 0", :order => "users_count DESC", :limit => 100)
      @metro_areas_for_cloud = @metro_areas_for_cloud.sort_by{|m| m.name}
  end  

  def setup_locations_for(user)
      metro_areas = []
      if user.state
        metro_areas = @sitter.state.metro_areas
      elsif user.country
        metro_areas = user.country.metro_areas
      end
      states = user.country.eql?(Country.get(:us)) ? State.find(:all) : []    
      return metro_areas, states
    end

  def admin_or_current_user_required
      current_user && (current_user.admin? || @is_current_user) ? true : access_denied     
  end
  
  
end
