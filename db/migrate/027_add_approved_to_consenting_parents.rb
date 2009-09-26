class AddApprovedToConsentingParents < ActiveRecord::Migration
  def self.up
     add_column :consenting_parents, :approved, :boolean, :default => 0
  end

  def self.down
    remove_column :consenting_parents, :approved
  end
end
