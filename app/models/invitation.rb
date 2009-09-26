class Invitation < ActiveRecord::Base
  belongs_to :user
  
  after_save :send_invite

  validates_presence_of :user
  validates_presence_of :email_addresses
  validates_length_of :email_addresses, :minimum => 6
  validates_length_of :email_addresses, :maximum => 1500

  validates_each :email_addresses do |record, attr, email_addresses |
    invalid_emails = []
    email_addresses = email_addresses || ''
    emails = email_addresses.split(",").collect{|email| email.strip }.uniq
    emails.each{ |email|
      unless email =~ /[\w._%-]+@[\w.-]+.[a-zA-Z]{2,4}/
        invalid_emails << email
      end        
    }
    unless invalid_emails.empty?
      record.errors.add(:email_addresses, " included invalid addresses: <ul>"+invalid_emails.collect{|email| '<li>'+email+'</li>' }.join+"</ul>")
      record.email_addresses = (emails - invalid_emails).join(', ')
    end
  end
  
  def send_invite(addresses)
    message = "this is cool stuff"
    emails = addresses.split(', ').collect{|email| email.strip }.uniq
    # if self.user.role = "parent"
    #   emails.each do |email|
    #     ParentMailer.deliver_signup_invitation(email, self.user, message)
    #   end
    # elsif self.user.role = "sitter"
      emails.each do |email|
        SitterMailer.deliver_signup_invitation(email, User.find(:first), message)
      end
    # end
   end
end
