class ConnectionsController < ApplicationController
  before_filter :login_required, :except => [:accept_from_email]
  skip_before_filter :direct_to_current_state
  layout 'bare'
  

  def add_friend
    if request.post?
#      Message.create(:recipient_id => params[:id], :user_id => current_user.id, :subject => "Connection Request", :body => params[:message][:description])
      Friendship.request(current_user, User.find(params[:id]))
      Notifications.deliver_connection_request(current_user, User.find(params[:id]), params[:message][:description])
      if (User.find(params[:id]).is_a?Sitter)
        if Sitter.find_by_id(params[:id]).underage?
          if Sitter.find_by_id(params[:id]).consenting_parent.notify_child_added  
            Notifications.deliver_underaged_connection_request(current_user, Sitter.find_by_id(params[:id]))
          end
        end
      end
      flash.now[:notice] = "Invitation sent."
    else  
      render :layout => "lightbox"
    end
    
  end
  
    def add_sitter
      if request.post?
  #      Message.create(:recipient_id => params[:id], :user_id => current_user.id, :subject => "Connection Request", :body => params[:message][:description])
        Friendship.request(current_user, User.find(params[:id]))
        Notifications.deliver_connection_request(current_user, User.find(params[:id]), params[:message][:description])
        if (User.find(params[:id]).is_a?Sitter)
          if Sitter.find_by_id(params[:id]).underage?
            if Sitter.find_by_id(params[:id]).consenting_parent.notify_child_added  
              Notifications.deliver_underaged_connection_request(current_user, Sitter.find_by_id(params[:id]))
            end
          end
        end
        flash.now[:notice] = "Invitation sent."
      else  
        render :layout => "lightbox"
      end

    end
  

  def view
    #need to convert to friends of parent clicked
    @families = Parent.find(:all)
    @sitters = Sitter.find(:all)
    render :layout => 'bare'
  end

  def show
    @user = User.find(params[:id])
    @friends = []
    my_friends_match_their_friends = false
 
 
    @selected_user_accepted_friends ||= @user.accepted_friendships
    @current_user_accepted_friends ||= current_user.accepted_friendships
    
    @selected_user_accepted_friends.each do |their_friend|
      @current_user_accepted_friends.each do |friend|
        if their_friend.friend == friend.friend
          my_friends_match_their_friends = true
        end
      end
    end

    @selected_user_accepted_friends.each do |af|
      
        if @user.profile.visible_to_everyone #&& (Friendship.find(:first, :conditions => ["user_id = ? AND friend_id = ?", current_user.id, af.friend.id]).status == 'accepted') rescue true)
             unless af.hide_connection 
               @friends << User.find(af.friend.id) 
             end   
        elsif @user.profile.visible_to_everyone == false  
 
          if @current_user_accepted_friends.collect{|f| f.friend}.include?(@user) || my_friends_match_their_friends
            unless af.hide_connection 
              @friends << User.find(af.friend.id) 
            end
          end
        end
    end
    
    render :layout => 'lightbox'
  end

  def accept
  
   if Friendship.accept(current_user, User.find(params[:id]))
     
     if current_user.is_a?Parent
       Notifications.deliver_accepted_parent_connection(current_user, User.find(params[:id]))
     elsif current_user.is_a?Sitter
       Notifications.deliver_accepted_sitter_connection(current_user, User.find(params[:id]))
       
       if current_user.underage?
         if current_user.consenting_parent.notify_child_added
           Notifications.deliver_accepted_sitter_connection_to_parent(current_user, User.find(params[:id]))
          end
        end
       
     end
       flash[:notice] = 'Friendship was accepted.'
       #flash.discard
     if current_user.is_a?Parent
       redirect_to connection_requests_parent_path(current_user)
       
     elsif current_user.is_a?Sitter
       redirect_to connection_requests_sitter_path(current_user)
       
     end
   
   else
     flash[:error] = "There was a problem."  
     #flash.discard
   end     
  end
  
  def accept_from_email
     unless logged_in?
        session[:accept_from_email] = params[:id]
        redirect_to :controller => :sessions, :action => 'new'
        return
      else
        if current_user.is_a?Parent
           redirect_to connection_requests_parent_path(current_user)

         elsif current_user.is_a?Sitter
           redirect_to connection_requests_sitter_path(current_user)

         end
      end
  end
  
  def decline
   if Friendship.breakup(current_user, User.find(params[:id]))
     redirect_to :back
     
     if User.find(params[:id]).is_a?Parent 
       flash[:notice] = 'Friend was removed.'
       #flash.discard
      else
       flash[:notice] = 'Sitter was removed'
       #flash.discard
     end
     else
     flash[:error] = "There was a problem." 
     #flash.discard 
     end
  end


  def edit
  end

  def update
  end
end
