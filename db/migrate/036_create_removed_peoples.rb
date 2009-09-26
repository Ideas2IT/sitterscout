class CreateRemovedPeoples < ActiveRecord::Migration
  def self.up
    create_table :removed_peoples do |t|
      t.integer :user_id
      t.integer :removed_user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :removed_peoples
  end
end
