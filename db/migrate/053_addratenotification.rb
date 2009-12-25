class Addratenotification < ActiveRecord::Migration
  def self.up
    add_column :jobs, :rate_notification, :boolean, :default => false
  end

  def self.down
    remove_column :job, :rate_notification
  end
end
