class AddFacebookId < ActiveRecord::Migration
  def self.up
    add_column :users,:facebook_id, :double, :default => 0    
  end

  def self.down
    remove_column :users, :facebook_id    
  end
end
