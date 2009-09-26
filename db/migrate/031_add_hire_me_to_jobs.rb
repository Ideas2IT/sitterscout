class AddHireMeToJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :type, :string
  end

  def self.down
    remove_column :jobs, :type
  end
end
