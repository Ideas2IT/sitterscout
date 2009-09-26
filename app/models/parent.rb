class Parent < User
  acts_as_paranoid
  has_one :profile, :dependent => :destroy
  has_many :jobs
  has_many :confirmed_sitters
  has_many :sitters, :through => :confirmed_sitters
  has_many :children

  acts_as_state_machine :initial => :new_account, :column => 'aasm_state'
  
  state :new_account
  state :welcome
  state :add_children
  state :add_friends
  state :add_sitters
  state :complete
  
  event :create_parent do
    transitions :from => :new_account, :to => :welcome
  end

  event :create_children do
    transitions :from => :welcome, :to => :add_children
  end
  
  event :create_friends do
    transitions :from => :add_children, :to => :add_friends
  end
  
  event :create_sitters do
    transitions :from => :add_friends, :to => :add_sitters
  end
  
  event :complete do
    transitions :from => :add_sitters, :to => :complete
  end
  
 # after_create {|user| ParentMailer.deliver_signup_notification(user) }
  #after_save   {|user| ParentMailer.deliver_activation(user) if user.recently_activated? }
  
  def self.find(*args)
    with_scope(:find => {:include => :profile, :conditions => ["profiles.parent_id IS NOT NULL"]}) do 
      super
    end
  end
  

end