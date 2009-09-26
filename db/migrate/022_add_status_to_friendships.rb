class AddStatusToFriendships < ActiveRecord::Migration
  def self.up
    add_column :friendships, :status, :string
  end

  def self.down
    remove_column :friendships, :status
  end
end
