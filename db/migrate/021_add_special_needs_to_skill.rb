class AddSpecialNeedsToSkill < ActiveRecord::Migration
  def self.up
    add_column :skills, :specialneeds, :boolean
    add_column :skills, :multiples, :boolean
  end

  def self.down
    remove_column :skills, :multiples
    remove_column :skills, :specialneeds
  end
end
