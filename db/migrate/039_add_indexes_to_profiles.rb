class AddIndexesToProfiles < ActiveRecord::Migration
  def self.up
    add_index :profiles, :sitter_id
    add_index :profiles, :parent_id
    add_index :photos, :user_id
    add_index :jobs, :parent_id
    add_index :jobs, :sitter_id
    add_index :request_sitters, :request_id
    add_index :request_sitters, :sitter_id
  end

  def self.down
    remove_index :profiles, :sitter_id
    remove_index :profiles, :parent_id
    remove_index :profiles, :user_id
    remove_index :photos, :user_id
    remove_index :jobs, :parent_id
    remove_index :jobs, :sitter_id
    remove_index :request_sitters, :request_id
    remove_index :request_sitters, :sitter_id
  end
end
