class ChangeZipcodeToString < ActiveRecord::Migration
  def self.up
    change_column :profiles, :zipcode, :string
  end

  def self.down
  end
end
