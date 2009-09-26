class AddMinorToUserTable < ActiveRecord::Migration
  def self.up
    add_column :users, :minor, :boolean, :default => 0

  end

  def self.down
    remove_column :users, :minor
  end
end
