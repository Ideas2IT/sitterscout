class Friendship < ActiveRecord::Base
  belongs_to :user, :with_deleted => true
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  validates_presence_of :user_id, :friend_id
  
  
  # Return true if the users are (possibly pending) friends.
  def self.exists?(user, friend)
    not find_by_user_id_and_friend_id(user, friend).nil?
  end
  
  # Record a pending friend request.
  def self.request(user, friend)
    unless user == friend or Friendship.exists?(user, friend)
      transaction do
        create(:user => user, :friend => friend, :initiator => true, :status => 'pending')
        create(:user => friend, :friend => user, :initiator => false, :status => 'requested')
      end
    end
  end
  
  # Accept a friend request.
  def self.accept(user, friend)
    transaction do
      accepted_at = Time.now
      accept_one_side(user, friend, accepted_at)
      accept_one_side(friend.id, user.id, accepted_at)
    end
  end
  
  # Delete a friendship or cancel a pending request.
  def self.breakup(user, friend)
    transaction do
      destroy(find_by_user_id_and_friend_id(user, friend))
      destroy(find_by_user_id_and_friend_id(friend, user))
    end
  end
  
  private
  
  # Update the db with one side of an accepted friendship request.
  def self.accept_one_side(user, friend, accepted_at)
    request = find_by_user_id_and_friend_id(user, friend)
    request.status = 'accepted'
    request.accepted_at = accepted_at
    request.save!
  end
  
  def self.friends_parent
    Friendship.find(:all ,:joins => "inner join users u on u.id = friendships.friend_id where u.type = 'Parent'")
#    :select => "DISTINCT(friendships.friend_id)"
#   Friendship.find_by_sql("SELECT * from friendships f WHERE  f.friend_id  IN (SELECT DISTINCT (f.friend_id) FROM friendships f INNER JOIN users u on u.id = f.friend_id WHERE u.type = 'Parent')")
  end
end