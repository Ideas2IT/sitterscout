class ConsentingParent < ActiveRecord::Base
  has_one :underaged_sitter, :class_name => "Sitter", :foreign_key => 'consenting_parent_id'
  
  validates_presence_of :name
  validates_presence_of :email
end
