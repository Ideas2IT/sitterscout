class RequestSitter < ActiveRecord::Base
  belongs_to :sitter
  belongs_to :request

  acts_as_state_machine :initial => :awaiting
  
  state :awaiting
  state :accepted
  state :declined
  state :cancelled
end