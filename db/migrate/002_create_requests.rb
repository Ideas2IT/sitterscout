class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.integer :job_id
      t.string :status
      t.timestamps
    end
    
    create_table :request_sitters do |t|
      t.integer :request_id
      t.integer :sitter_id
      t.string :state
    end
  end

  def self.down
    drop_table :requests
    drop_table :requests_sitters
  end
end
