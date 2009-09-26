require File.dirname(__FILE__) + '/../test_helper'

class AdminControllerTest < ActionController::TestCase
  fixtures :users, :roles
  
  def test_gets_index
   login_as :admin
   get :index
   assert_response :success
  end
  
  def test_should_redirect_trying_to_get_index_because_not_logged_in
    get :index
    assert_response :redirect
  end
  
  def test_should_redirect_trying_to_get_index_because_not_admin
    login_as :patrick
    get :index
    assert_response :redirect
  end
  
  def test_should_delete_user
    login_as :admin
    user = users(:user_00037)
    post :delete_user, :id => user.id
    assert_response :success
    assert_nil User.find(:first, :conditions => "id = #{user.id}")
  end
  
end
