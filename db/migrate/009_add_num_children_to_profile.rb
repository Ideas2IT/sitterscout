class AddNumChildrenToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :num_children, :integer
  end

  def self.down
    remove_column :profiles, :num_children
  end
end
