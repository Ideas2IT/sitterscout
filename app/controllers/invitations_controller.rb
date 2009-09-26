class InvitationsController < ApplicationController
  skip_before_filter :direct_to_current_state
#protect_from_forgery :secret => '66e4f871a737d1c50b0d702fd5c311c6'

# before_filter :require_current_user, :only => [:create, :edit, :update, :destroy]
# GET /invitations
# GET /invitations.xml
def index
  @user = User.find(params[:user_id])    
  @invitations = @user.invitations

  respond_to do |format|
    format.html # index.rhtml
    format.xml  { render :xml => @invitations.to_xml }
  end
end

# GET /invitations/1
# GET /invitations/1.xml
def show
  @invitation = Invitation.find(params[:id])

  respond_to do |format|
    format.html # show.rhtml
    format.xml  { render :xml => @invitation.to_xml }
  end
end

def new

  @user = self.current_user
  @invitation = Invitation.new
  
  respond_to do |format|
    format.js
    format.html
  end
  
 end
# 
# GET /invitations/1;edit
def edit
  @invitation = Invitation.find(params[:id])
end

# POST /invitations
# POST /invitations.xml
def create
  @user = User.find(params[:user_id])

  @invitation = Invitation.new(params[:invitation])
  @invitation.user = @user

  respond_to do |format|
    if @invitation.save
      flash[:notice] = 'Invitation was successfully created.'
      #flash.discard
      format.html { 
        unless params[:welcome]
          redirect_to user_path(@invitation.user) 
        else
          redirect_to welcome_complete_user_path(@invitation.user)            
        end
      }
    else
      format.html { render :action => "new" }
    end
  end
end

end