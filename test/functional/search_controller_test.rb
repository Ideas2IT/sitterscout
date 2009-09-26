require File.dirname(__FILE__) + '/../test_helper'

class SearchControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  fixtures :users, :roles, :profiles
  
  
  def setup
    @controller = FriendshipsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_should_get_index
    # get :index
    # assert_response :success
    # assert assigns(:ret)
    # assert assigns(:items_per_page)
  end
  
  def test_should_get_no_results
    # get :index, "topsearch[search_string]" => '23424234efjsnfs'
    # assert_response :success
    # assert assigns(:ret).empty?
    # 
  end
  
  
end
