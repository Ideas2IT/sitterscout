class AddAcceptedAtToFriendship < ActiveRecord::Migration
  def self.up
    add_column :friendships, :accepted_at, :datetime
  end

  def self.down
    remove_column :friendships, :accepted_at
  end
end
