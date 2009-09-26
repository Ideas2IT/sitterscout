class AddDaysToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :mondays, :string
    add_column :profiles, :tuesdays, :string
    add_column :profiles, :wednesdays, :string
    add_column :profiles, :thursdays, :string
    add_column :profiles, :fridays, :string
    add_column :profiles, :saturdays, :string
    add_column :profiles, :sundays, :string
  end

  def self.down
    remove_column :profiles, :sundays
    remove_column :profiles, :saturdays
    remove_column :profiles, :fridays
    remove_column :profiles, :thursdays
    remove_column :profiles, :wednesdays
    remove_column :profiles, :tuesdays
    remove_column :profiles, :mondays
  end
end
