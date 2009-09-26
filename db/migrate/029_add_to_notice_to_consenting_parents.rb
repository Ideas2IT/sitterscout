class AddToNoticeToConsentingParents < ActiveRecord::Migration
  def self.up
    add_column :consenting_parents, :notify_child_added, :boolean
    add_column :consenting_parents, :notify_parent_request, :boolean
  end

  def self.down
    remove_column :consenting_parents, :notify_parent_request
    remove_column :consenting_parents, :notify_child_added
  end
end
