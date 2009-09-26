require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < Test::Unit::TestCase
  fixtures :users, :roles

  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # def test_should_login_and_redirect
  #   post :create, :login => 'quentin', :password => 'test'
  #   assert session[:user]
  #   assert_response :redirect
  # end

  def test_should_fail_login_and_redirect
    @request.env["HTTP_REFERER"] = '/parents'
    post :create, :login => 'quentin', :password => 'bad password'
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_logout
    login_as :patrick
    get :destroy
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_remember_me
#    post :create, :login => 'quentin', :password => 'test', :remember_me => "1"
#    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
#    post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
#    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as :patrick
    get :destroy
    assert_equal @response.cookies["auth_token"], []
  end

  def test_should_login_with_cookie
    users(:patrick).remember_me
    @request.cookies["auth_token"] = cookie_for(:patrick)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:patrick).remember_me
    users(:patrick).update_attribute :remember_token_expires_at, 5.minutes.ago.utc
    @request.cookies["auth_token"] = cookie_for(:patrick)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    @request.env["HTTP_REFERER"] = '/parents'
    users(:patrick).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_redirect_to_home_page
    login_as :patrick
    get :destroy
    assert_redirected_to(home_page_path)
  end
  
  def test_should_redirect_suspended_user_to_home_page
    post :create, :login => 'siteadmin2@sittercout.com', :password => 'abc123'
    assert_redirected_to(:controller => 'parents', :action => 'index')
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
