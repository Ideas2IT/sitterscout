class RemovedPeople < ActiveRecord::Base
  
  validates_numericality_of :user_id, :only_integer => 'true'
  validates_numericality_of :removed_user_id, :only_integer => 'true'
  
  
  def self.find_users_removed_people_ids(user)
#   cf = find_all_by_user_id(user, :select => 'removed_user_id')
   cf= find(:all,:select => 'removed_user_id',:conditions => ['id =?',user])
   
   ids = [];
   cf.each do |f|
     ids << f.removed_user_id
   end
     
   return ids
  end
end