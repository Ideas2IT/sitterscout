class CreateSitterRatings < ActiveRecord::Migration
  def self.up
    create_table :sitter_ratings do |t|
      t.integer :sitter_id 
      t.integer :parent_id
      t.integer :my_request
      t.integer :arr_time
      t.integer :asked
      t.integer :condition
      t.integer :my_child
      t.text :comment 
      t.timestamps
    end
  end

  def self.down
    drop_table :sitter_ratings
  end
end
