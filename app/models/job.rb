class Job < ActiveRecord::Base
  [:parent, :sitter].each do |r|
    belongs_to r
  end
  
  has_many :requests
  
  # acts_as_state_machine :initial => :awaiting, :column => 'status'
  # 
  # state :awaiting
  # state :accepted
  # state :declined
  # state :cancelled
  
  def self.job_all
    Job.find(:all)
  end
  
end
