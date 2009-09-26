class UpdateEmailDefault < ActiveRecord::Migration
  def self.up
    change_column_default(:profiles, :email, 1)
  end

  def self.down
    change_column_default(:profiles, :email, 0)
  end
end
