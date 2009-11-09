class AddIndexIdRemovedPeoples < ActiveRecord::Migration
  def self.up
    add_index :removed_peoples, :user_id
  end

  def self.down
    remove_index :removed_peoples, :user_id
  end
end
