require File.dirname(__FILE__) + '/../test_helper'

class ZipCodesControllerTest < ActionController::TestCase
  fixtures :zip_codes
  
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:zip_codes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_zip_code
    assert_difference ZipCode, :count do
      post :create, :zip_code => { }
    end

    assert_redirected_to zip_code_path(assigns(:zip_code))
  end

  def test_should_show_zip_code
    get :show, :id => zip_codes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => zip_codes(:one).id
    assert_response :success
  end

  def test_should_update_zip_code
    put :update, :id => zip_codes(:one).id, :zip_code => { }
    assert_redirected_to zip_code_path(assigns(:zip_code))
  end

  def test_should_destroy_zip_code
    assert_difference ZipCode, :count, -1 do
      delete :destroy, :id => zip_codes(:one).id
    end

    assert_redirected_to zip_codes_path
  end
end
