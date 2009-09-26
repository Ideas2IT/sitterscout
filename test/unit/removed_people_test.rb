require File.dirname(__FILE__) + '/../test_helper'

class RemovedPeopleTest < ActiveSupport::TestCase
  fixtures :users

  def test_should_create_removed_people
    assert_difference RemovedPeople, :count do
      rp = create_removed_people
      assert !rp.new_record?, "#{rp.errors.full_messages.to_sentence}"
    end
  end
  
  
  def test_should_require_user_id
    assert_no_difference RemovedPeople, :count do
      rp = create_removed_people(:user_id => nil)
      assert rp.new_record?, "#{rp.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_require_removed_user_id
    assert_no_difference RemovedPeople, :count do
      rp = create_removed_people(:removed_user_id => nil)
      assert rp.new_record?, "#{rp.errors.full_messages.to_sentence}"
    end
  end
  
  
  def test_should_return_users_removed_people
    ug = create_removed_people(:user_id => users(:patrick).id)
    assert(RemovedPeople.find_users_removed_people_ids(users(:patrick)).include?(1))
  end

protected 

  def create_removed_people(options = {})
      record = RemovedPeople.new({:user_id => 5, :removed_user_id => 1}.merge(options))
      record.save
      record
    end
end
