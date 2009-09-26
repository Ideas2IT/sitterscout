class AddFullNameToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :full_name, :string
  end

  def self.down
    remove_column :profiles, :full_name
  end
end
