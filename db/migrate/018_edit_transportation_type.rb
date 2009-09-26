class EditTransportationType < ActiveRecord::Migration
  def self.up
    remove_column :skills, :transportation
    add_column :skills, :transportation, :string
  end

  def self.down
    remove_column :skills, :transportation
    add_column :skills, :transportation, :boolean
  end
end
