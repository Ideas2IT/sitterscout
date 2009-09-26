class AddConsentingParentIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :consenting_parent_id, :integer
  end

  def self.down
    remove_column :users, :consenting_parent_id
  end
end
