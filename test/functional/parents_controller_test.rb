require File.dirname(__FILE__) + '/../test_helper'
require 'parents_controller'

class ParentsController; def rescue_action(e) raise e end; end

class ParentsControllerTest < ActionController::TestCase
  
  fixtures :profiles, :users, :states, :roles
  
  
  def test_should_get_index
    login_as :patrick
    get :index
    assert_redirected_to(dashboard_parent_path(users(:patrick)))
  end
  
  

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_edit
    assert true
  end
  
  
  def test_create
    assert true
  end
  
  def test_dashboard
    assert true
  end
  
  def test_check_availability
    login_as :patrick
    post :check_availability, {'date_from_hour' => '1', 'date_from_min' => '15', 'date_from_period' => 'AM', 'date' => "October 25, 2008", 'date_to_hour' => '1', 'date_to_min' => '30', 'date_to_period'  => 'AM'} 
    assert_response :success
    assert_template nil
  end
  
  def test_remove_person
    @request.env["HTTP_REFERER"] = '/parents/friends'
    login_as :patrick
    xhr :post, :remove_person, {'removed_user_id' => '5' } 
    assert_response :redirect
  end
  
  def test_cancel_job
    assert true
  end
  
  def test_my_children
    assert true
  end
  
  def test_update_my_children
    assert true
  end
  
  def test_update_sitters
    login_as :user_with_state_as_new_account
    post :update_sitters
    assert_equal "add_sitters", Parent.find(users(:user_with_state_as_new_account)).aasm_state
    assert_redirected_to invite_parent_path(users(:user_with_state_as_new_account))
  end
  
  def test_sitters_with_no_confirmed_or_unconfirmed_sitters
    login_as :user_with_state_as_new_account
    get :sitters
    assert_nil assigns(:sitters)
    assert_nil assigns(:confirmed_sitters)
    assert_nil assigns(:unconfirmed_sitters)
  end

  def test_sitters_with_confirmed_but_no_unconfirmed_sitters
    assert false
  end

  def test_sitters_with_no_confirmed_but_has_unconfirmed_sitters
    assert false
  end

     
  def test_should_create_profile
    #assert_difference('Profile.count') do
    #    post :create, :profile => { }
    #end
    #assert_redirected_to profile_path(assigns(:profile))
  end
  
  def test_sitters
    assert true
  end
  
  def test_should_show_profile
    login_as(:patrick)
    get :view_profile, :id => profiles(:profile_00006).id
    assert_response :success
  end
  
  #def test_should_get_edit
  #  login_as (:patrick)
  #  get :edit, :id => profiles(:profile_00006).id
  #  assert_response :success
  #end
  
  def test_should_update_profile
    # login_as(:patrick)
    # put :update, :id => profiles(:profile_00006).id, :profile => { }
    # assert_redirected_to profile_path(assigns(:profile))
  end

  def test_search_friends
  end
  
  def test_your_sitters
  end
  
  def test_my_profile
  end
  
  def test_activate
  end
  
  def test_update_friend
  end
  
  def test_update_your_friends
  end
  
  def test_your_friends
  end
  
  def test_welcome
  end
  
  def test_send_invitations
  end
  
end
