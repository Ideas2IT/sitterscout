class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :to
      t.integer :from
      t.text :message
      t.datetime :date_sent
      t.datetime :date_received

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
