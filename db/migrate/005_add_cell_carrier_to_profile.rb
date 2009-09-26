class AddCellCarrierToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :cell_carrier_id, :integer
  end

  def self.down
    remove_column :profiles, :cell_carrier_id
  end
end
