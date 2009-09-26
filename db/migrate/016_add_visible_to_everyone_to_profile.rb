class AddVisibleToEveryoneToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :visible_to_everyone, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :visible_to_everyone
  end
end
