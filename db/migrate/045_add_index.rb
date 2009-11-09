class AddIndex < ActiveRecord::Migration
  
  def self.up
   
    add_index :simple_captcha_data, :updated_at
    add_index :users, [:deleted_at, :email]
    add_index :countries, :name
    add_index :profiles, [:not_searchable, :parent_id]
    add_index :users, :deleted_at
    add_index :users, :type
    add_index :tags, :name
    add_index :profiles, [:full_name, :first_name]
    add_index :profiles, [:last_name, :not_searchable]
   
  end

  def self.down
   
    remove_index :simple_captcha_data, :updated_at
    remove_index :users, [:deleted_at, :email]
    remove_index :countries, :name
    remove_index :profiles, [:not_searchable, :parent_id]
    remove_index :users, :deleted_at
    remove_index :users, :type
    remove_index :tags, :name
    remove_index :profiles, [:full_name, :first_name]
    remove_index :profiles, [:last_name, :not_searchable]
   
  end
end