require File.dirname(__FILE__) + '/../test_helper'

class NotificationsTest < ActionMailer::TestCase
  tests Notifications
  def test_new_message
    @expected.subject = 'Notifications#new_message'
    @expected.body    = read_fixture('new_message')
    @expected.date    = Time.now

    #assert_equal @expected.encoded, Notifications.create_new_message(@expected.date).encoded
  end

end
