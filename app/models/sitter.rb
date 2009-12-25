class Sitter < User
  acts_as_paranoid
  has_one :profile, :dependent => :destroy
  has_one :skill
  has_many :confirmed_sitters
  has_many :parents, :through => :confirmed_sitters
  has_many :request_sitters
  has_many :sitter_ratings
  has_many :requests, :through => :request_sitters
  has_many :accepted_jobs, :class_name => "Job", :conditions => "status = 'accepted'"

  belongs_to :consenting_parent
  validates_presence_of :birthday

  after_create :create_skill
  

  acts_as_state_machine :initial => :new_account, :column => 'aasm_state'
  
  
  state :new_account
  state :welcome
  state :add_friends
  state :add_sitters
  state :complete


  def all_confirmed_families
     ConfirmedSitter.find(:all, :conditions => ["sitter_id = ? and aasm_state = ?", self.id, "accepted"])
   end

   def all_unconfirmed_families
    ConfirmedSitter.find(:all, :conditions => ["sitter_id = ? and aasm_state = ?", self.id, "awaiting"])
   end

   def underage?
     unless self.birthday.nil?
       18.years.ago < self.birthday.to_time
     end
   end
   
   def self.find(*args)
     with_scope(:find => {:include => [ {:profile => [:state, :tags]}, :tags, :accepted_friendships], :conditions => ["profiles.sitter_id IS NOT NULL"]}) do 
       super
     end
   end

  protected

  def validate
   # errors.add(:birthday, "Underage") if self.underage? && self.minor.nil?
  end
  
  def create_skill
    skill = Skill.create
  end

  
end