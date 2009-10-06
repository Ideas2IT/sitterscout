class AddIndexRemovedPeoples < ActiveRecord::Migration
  def self.up
    add_index :removed_peoples , :user_id
    add_index :removed_peoples , :removed_user_id
  end

  def self.down
    remove_index :removed_peoples , :user_id
    remove_index :removed_peoples , :removed_user_id
  end
end
