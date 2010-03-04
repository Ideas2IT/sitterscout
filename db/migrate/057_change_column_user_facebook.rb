class ChangeColumnUserFacebook < ActiveRecord::Migration
  def self.up
    change_column :users, :facebook_id, :double ,  :unique => true
  end

  def self.down
  end
end
