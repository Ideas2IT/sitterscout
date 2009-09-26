require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users, :states, :metro_areas, :friendships, :roles, :friendship_statuses

  def test_should_create_user
    assert_difference User, :count do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_create_parent
    assert_difference Parent, :count do
      parent = create_parent
      assert !parent.new_record?, "#{parent.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_create_sitter
    assert_difference Sitter, :count do
      sitter = create_sitter
      assert !sitter.new_record?, "#{sitter.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_not_reject_spaces
    user = User.new(:login => 'foo bar')
    user.valid?
    assert !user.errors.on(:login)
  end

  def test_should_require_login
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end
  
  def test_should_find_user_with_numerals_in_login
#    u = create_user(:login => "2foo-and-bar")
#    assert !u.errors.on(:login)
#    assert_equal u, User.find("2foo-and-bar")
  end

  def test_should_require_password
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference User, :count do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end
  
  def test_should_require_birthday
    assert_no_difference User, :count do
      u = create_user(:birthday => nil)
      assert u.errors.on(:birthday)
      
    end
  end  

#  def test_should_handle_email_upcase
#    assert_difference User, :count, 1 do
#      assert create_user(:email => 'BENMOORE@BENMOORE.NET').valid?
#    end
#  end

  def test_should_reset_password
  #    users(:patrick).update_attributes(:password => 'new password', :password_confirmation => 'new password')
  #  assert_equal users(:patrick), User.authenticate('patrick@glific.com', 'new password')
  end

  
  def test_should_not_rehash_password
    users(:patrick).update_attributes(:login => 'quentin_two')
    assert_equal users(:patrick), User.authenticate('quentin_two', 'pkpkpk')
  end

  def test_should_authenticate_user
    assert_equal users(:patrick), User.authenticate('pkenney@pmkenney.com', 'pkpkpk')
  end

  
  def test_should_set_remember_token
    users(:patrick).remember_me
    assert_not_nil users(:patrick).remember_token
    assert_not_nil users(:patrick).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:patrick).remember_me
    assert_not_nil users(:patrick).remember_token
    users(:patrick).forget_me
    assert_nil users(:patrick).remember_token
  end
  
#  def test_should_show_location
#   # assert_equal users(:user_986324922).location, metro_areas(:twincities).name
#  end
#  
  def test_should_call_avatar_photo
#    assert_equal users(:patrick).avatar_photo_url, AppConfig.photo['missing_medium']
#    assert_equal users(:patrick).avatar_photo_url(:thumb), AppConfig.photo['missing_thumb']
  end
  
  def test_should_get_active_users
    active_users = User.find_active
    assert !active_users.empty? #none have avatar photos
  end
  
  def test_should_test_delete_user_with_paranoia
    user = create_user(:email => 'testdeleteuser@test.com')
    assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    user.destroy
    assert_nil User.find(:first, :conditions => "email = 'testdeleteuser@test.com'")
    user = User.find_with_deleted(:first, :conditions => "email = 'testdeleteuser@test.com'")
    assert_not_nil user
    user.deleted_at = nil
    user.save
    assert_not_nil User.find(:first, :conditions => "email = 'testdeleteuser@test.com'")
  end
  
  def test_should_test_suspended_user
    user = create_user(:email => 'testdeleteuser@test.com')
    assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    assert_equal user.suspended?, false
    user.suspended = true
    user.save
    assert_equal user.suspended?, true
  end
  
  protected
    def create_user(options = {})
      User.create({ :login => 'quire', 
          :email => 'quire@example.com', :password => 'quire123', :password_confirmation => 'quire123', :birthday => 14.years.ago, :terms_of_use => true }.merge(options))
    end
    
    def create_parent(options = {})
      Parent.create({ :login => 'quire', 
          :email => 'quire@example.com', :password => 'quire123', :password_confirmation => 'quire123', :birthday => 14.years.ago, :terms_of_use => true }.merge(options))
    end
    
    def create_sitter(options = {})
      Sitter.create({ :login => 'quire', 
          :email => 'quire@example.com', :password => 'quire123', :password_confirmation => 'quire123', :birthday => 14.years.ago, :terms_of_use => true }.merge(options))
    end
end
