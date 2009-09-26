class AddHideConnectionToFriendships < ActiveRecord::Migration
  def self.up
    add_column :friendships, :hide_connection, :boolean, :default => 0
  end

  def self.down
    remove_column :friendships, :hide_connection
  end
end
