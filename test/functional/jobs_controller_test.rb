require File.dirname(__FILE__) + '/../test_helper'

require 'jobs_controller'

class JobsController; def rescue_action(e) raise e end; end

class JobsControllerTest < ActionController::TestCase
  fixtures :jobs, :users
  
  def test_should_get_index
    get :index
    assert_response :success
    #assert_not_nil assigns(:jobs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

 def test_should_create_job
   # login_as :user_986324922
   # assert_difference Job, :count do
   #   post :create, :job => { }
   # end
   # 
   # assert_redirected_to dashboard_parent_path(assigns(current_user))
 end

  # def test_should_show_friend
  #   get :show, :id => friends(:one).id
  #   assert_response :success
  # end

  def test_should_get_edit
    # login_as :user_986324922
    # get :edit, :id => jobs(:one).id
    # assert_response :success
  end

  def test_should_update_job
    # put :update, :id => friends(:one).id, :job => { }
    # assert_redirected_to job_path(assigns(:job))
  end

  def test_should_destroy_job
#    assert_difference Friend, :count, -1 do
#      delete :destroy, :id => friends(:one).id
#    end
#
#    assert_redirected_to friends_path
  end
end
