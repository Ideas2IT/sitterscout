module FriendshipHelper
  def friendship_status(user, friend)
    friendship = Friendship.find_by_user_id_and_friend_id(user, friend)
    return "#{friend.name} is not your friend (yet)." if friendship.nil?
    case friendship.status
    when 'requested'
      "#{friend.name} would like to be your friend."
    when 'pending'
      "You have requested friendship from #{friend.name}."
    when 'accepted'
      "#{friend.name} is your friend."
    end
  end
end
