require File.dirname(__FILE__) + '/../test_helper'

require "profiles_controller"

class ProfilesController; def rescue_action(e) raise e end; end

class ProfilesControllerTest < ActionController::TestCase
  fixtures :profiles, :states, :roles


  def test_should_get_new
    # get :new
    # assert_response :success
  end

  def test_should_create_profile
    # assert_difference Profile, :count do
    #   post :create, :profile => { }
    # end
    #   
    # assert_redirected_to profile_path(assigns(:profile))
  end

  def test_should_show_profile
    # get :show, :id => profiles(:profile_00028).id
    # assert_response :success
    # assert_not_nil nil
  end

  def test_should_get_edit
 #   get :edit, :id => profiles(:profile_00028).id
#    assert_response :success
  end

  def test_should_update_profile
    # put :update, :id => profiles(:profile_00028).id, :profile => { }
    # assert_redirected_to profile_path(assigns(:profile))
  end

  def test_should_destroy_profile
    # assert_difference Profile, :count, -1 do
    #   delete :destroy, :id => profiles(:profile_00028).id
    # end
    # 
    # assert_redirected_to profiles_path
  end
end
