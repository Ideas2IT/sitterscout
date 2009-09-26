class CreateCellCarriers < ActiveRecord::Migration
  def self.up
    create_table :cell_carriers do |t|
      t.string :name
      t.string :email_suffix

      t.timestamps
    end
    
    ["Att", "Sprint", "TMobile", "Cricket"].each do |c|
      CellCarrier.create(:name => c[0])
    end

    
  end

  def self.down
    drop_table :cell_carriers
  end
end
