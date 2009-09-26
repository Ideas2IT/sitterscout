class Request < ActiveRecord::Base
  belongs_to :job
  has_many :request_sitters
  has_many :sitters, :through => :request_sitters
  
  # acts_as_state_machine :initial => :awaiting, :column => 'status'
  # 
  # state :awaiting
  # state :accepted
  # state :declined
  
end
