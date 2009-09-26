class AddNotifierToJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :notification_sent, :boolean
  end

  def self.down
    remove_column :jobs, :notification_sent
  end
end
