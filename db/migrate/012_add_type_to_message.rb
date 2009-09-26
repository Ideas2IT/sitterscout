class AddTypeToMessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :type, :string
  end

  def self.down
    remove_column :messages, :type
  end
end
