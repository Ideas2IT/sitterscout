require File.dirname(__FILE__) + '/../test_helper'

require "sitters_controller"

class SittersController; def rescue_action(e) raise e end; end

class SittersControllerTest < ActionController::TestCase
  
  fixtures :all
  
 def test_should_get_index
    # login_as :user_00037
    # get :index
    # assert_redirected_to(dashboard_sitter_path(users(:user_00037)))
  end



   # def test_should_get_new
   #   get :new
   #   assert_response :success
   # end

 
  # def test_should_create_sitter
  #    assert_difference('Sitter.count') do
  #      post :create, :sitter => { }
  #    end
  # 
  #    assert_redirected_to sitter_path(assigns(:sitter))
  #  end
  
  
  def test_view_connections
    assert true
  end
  
  
  def test_add_family
    assert true
  end
  
  def test_update_families
    assert true
  end
  
  def test_update
    assert true
  end
  
  def test_your_skills
    assert true
  end
  
  def test_create_skills
    assert true
  end
  
  def test_dashboard
    assert true
  end
  
  def test_remove_person
    # @request.env["HTTP_REFERER"] = '/sitters/friends'
    #   
    #   login_as :user_00037
    #   post :remove_person, {'removed_user_id' => '5' } 
    #   assert_response :success
    #   assert_template nil
  end
  
  def test_your_requests
    assert true
  end
  
  def test_your_families
    assert true
  end
  
  def test_search_families
    assert true
  end
  
  def test_families
    assert true
  end
  
  def test_welcome
    assert true
  end
  
  def test_inbox
    assert true
  end
  
  def test_my_profile
    assert true
  end
  
  def test_create_friendship_with_inviter
    assert true
  end
  
  def test_activate
    assert true
  end
  
  def test_availability
    assert true
  end
  
  def test_send_invitations
    assert true
  end
  
  def test_decline_job
    post :decline_job, :id => requests(:request_996332880)
    
    
  end
  
  # #no update method right now
 #  def test_should_update_profile
 #    # put :update, :id => profiles(:quentin_profile).id, :profile => { }
 #    #  assert_redirected_to profile_path(assigns(:profile))
 #  end
 # 
 #  def test_should_destroy_profile
 #    assert_difference('Profile.count', -1) do
 #      delete :destroy, :id => profiles(:quentin_profile).id
 #    end
 # 
 #    assert_redirected_to profiles_path
 #  end
end
