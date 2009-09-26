class CreateConfirmedSitters < ActiveRecord::Migration
  def self.up
    create_table :confirmed_sitters do |t|
      t.integer :parent_id
      t.integer :sitter_id
      t.string :aasm_state

      t.timestamps
    end

  end

  def self.down
    drop_table :confirmed_sitters
  end
end
