class ChangeAgeFieldString < ActiveRecord::Migration
  def self.up
    remove_column :children, :age
    add_column :children, :age, :string
  end

  def self.down
    remove_column :children, :age
    add_column :children, :age, :integer
  end
end
