class AddIndexChildren < ActiveRecord::Migration
  def self.up
    add_index :children ,:parent_id
  end

  def self.down
    remove_index :children ,:parent_id
  end
end
