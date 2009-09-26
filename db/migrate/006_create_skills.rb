class CreateSkills < ActiveRecord::Migration
  def self.up
    create_table :skills do |t|
      t.boolean :babies
      t.boolean :toddlers
      t.boolean :preschoolers
      t.boolean :schoolaged
      t.boolean :cook
      t.boolean :homework
      t.boolean :bathe
      t.boolean :kidstobed
      t.boolean :entertain
      t.boolean :transportation
      t.integer :max_mileage
      t.integer :sitter_id

      t.timestamps
    end
  end

  def self.down
    drop_table :skills
  end
end
