require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

class UsersController; def rescue_action(e) end; end

class UsersControllerTest < ActionController::TestCase
  fixtures :friends, :users
  
#  def test_should_get_index
#    get :index
#    assert_response :success
#    assert_not_nil assigns(:friends)
#  end
#
##  def test_should_get_new
##    get :new
##    assert_response :success
##  end
#
#  def test_should_create_friend
#    login_as :user_986324922
#    assert_difference Friend, :count do
#      post :create, :friend => { }
#    end
#
#    assert_redirected_to friend_path(assigns(:friend))
#  end
#
#  # def test_should_show_friend
#  #   get :show, :id => friends(:one).id
#  #   assert_response :success
#  # end
#
#  def test_should_get_edit
#    get :edit, :id => friends(:one).id
#    assert_response :success
#  end
#
#  def test_should_update_friend
#    put :update, :id => friends(:one).id, :friend => { }
#    assert_redirected_to friend_path(assigns(:friend))
#  end
#
#  def test_should_destroy_friend
#    assert_difference Friend, :count, -1 do
#      delete :destroy, :id => friends(:one).id
#    end
#
#    assert_redirected_to friends_path
#  end
end
