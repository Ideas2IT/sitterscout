class ConfirmedSitter < ActiveRecord::Base
  belongs_to :parent
  belongs_to :sitter
  
  acts_as_state_machine :initial => :awaiting, :column => 'aasm_state'
  
  state :awaiting
  state :accepted
  state :declined
  
end
