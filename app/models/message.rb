# == Schema Information
# Schema version: 185
#
# Table name: messages
#
#  id                :integer(11)   not null, primary key
#  user_id           :integer(11)   
#  recipient_id      :integer(11)   
#  subject           :string(255)   
#  created_at        :datetime      
#  body              :text          
#  status            :string(255)   default("new")
#  sender_deleted    :boolean(1)    
#  recipient_deleted :boolean(1)    
#  deleted_at        :datetime      
#

class Message < ActiveRecord::Base
	DAILY_LIMIT = 50
	
	belongs_to :sender, :class_name => "User", :foreign_key => :user_id
	belongs_to :recipient, :class_name => "User", :foreign_key => :recipient_id
	#belongs_to :unread_recipient, :class_name => "User", :foreign_key => :recipient_id, :conditions => ["messages.recipient_deleted = ? AND messages.status = ?",0,'new'], :counter_cache => :unread_received_message_count
	
	belongs_to :user
	
  validates_presence_of :recipient_id, :on => :create, :message => "can't be blank"
	validates_presence_of :subject, :on => :create, :message => "can't be blank"
  # validates_each :body do |model, attr, value|
  #     model.errors.add(attr, "Body must be at least 10 characters") if value.size < 10 and !model.sender.is_admin?
  #     model.errors.add(attr, "Body must be less than 1000 characters") if value.size > 1000 and !model.sender.is_admin?
  # end
  # 
  # validates_each :subject do |model, attr, value|
  #     model.errors.add(attr, "Subject must be at least 5 characters") if value.size < 5 and !model.sender.is_admin?
  #     model.errors.add(attr, "Subject must be less than 30 characters") if value.size > 30 and !model.sender.is_admin?
  # end
  # 

	after_save { |message|
		if message.sender_deleted == 1 && message.recipient_deleted == 1
			message.destroy
		end
	 }
	 
	 
	
end
