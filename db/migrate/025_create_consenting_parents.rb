class CreateConsentingParents < ActiveRecord::Migration
  def self.up
    create_table :consenting_parents do |t|
      t.string :name
      t.string :email
      t.integer :underaged_sitter_id

      t.timestamps
    end
  end

  def self.down
    drop_table :consenting_parents
  end
end
