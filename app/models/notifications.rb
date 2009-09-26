class Notifications < ActionMailer::Base
    helper ActionView::Helpers::UrlHelper
  def connection_request(user, user2, message)
    content_type "text/html"
    @recipients  = "#{user2.email}"
    setup_sender_info
    @subject     = "You have a connection request on SitterScout"
    @sent_on     = Time.now
    @body[:user_1] = user2
    @body[:user_2] = user
    @body[:message] = message
    setup_sender_info
  end

#Notifications.deliver_underaged_connection_request(current_user, User.find(params[:id])
  def underaged_connection_request(user, sitter)
    content_type "text/html"
    @recipients = sitter.consenting_parent.email
    setup_sender_info
    @subject     = "SitterScout Connection Request"
    @sent_on     = Time.now
    @body[:sitter] = sitter
    @body[:parent] = user
    setup_sender_info
  end

  def parent_welcome(user)
    content_type "text/html"
    setup_sender_info
    @recipients  = "#{user.email}"
    setup_sender_info
    @subject     = "Welcome to SitterScout!"
    @sent_on     = Time.now
    @body[:user] = user
  end
  
  def parent_job_reminder(parent, sitter, job)
    content_type "text/html"
    setup_sender_info
    @recipients = parent.email
    @subject = 'SitterScout Job Reminder'
    @body[:sitter] = sitter
    @body[:parent] = parent
    @body[:job] = job
  end
  
  def sitter_job_reminder(parent, sitter, job)
    content_type "text/html"
    setup_sender_info
    @recipients = sitter.email
    @subject = 'SitterScout Job Reminder'
    @body[:sitter] = sitter
    @body[:parent] = parent
    @body[:job] = job
  end
  
  def parent_job_sms_reminder(parent, sitter, job)
    content_type "text/html"
    setup_sender_info
    @recipients = parent.email
    @subject = 'SitterScout Job Reminder'
    @body[:sitter] = sitter
    @body[:parent] = parent
    @body[:job] = job
  end
  
  def sitter_job_sms_reminder(parent, sitter, job)
    content_type "text/html"
    setup_sender_info
    @recipients = sitter.email
    @subject = 'SitterScout Job Reminder'
    @body[:sitter] = sitter
    @body[:parent] = parent
    @body[:job] = job
  end
  
  def sitter_welcome(user, msg=nil)
    content_type "text/html"
    setup_sender_info
    @recipients  = "#{user.email}"
    setup_sender_info
    @subject     = "Welcome to SitterScout!"
    @sent_on     = Time.now
    @body[:user] = user
  end
  
  def reset_password(user)
        content_type "text/html"
    setup_email(user)
    @subject    += "#{AppConfig.community_name} User information"
  end


	def new_message(message, host)
    content_type "text/html"
		setup_email(message.recipient)
		@subject = 'You have a message on SitterScout'
      @body[:sender_name] = message.sender.profile.full_name
      @body[:recipient] = message.recipient.profile.full_name
      @body[:message] = message.body
      @body[:message_id] = message.id
  		@body[:url] = host
	end
  
  
  def job_notice(sitter_email, parent, job, message=nil)
    content_type "text/html"
    setup_sender_info
    @recipients = sitter_email.email
    @subject = parent.profile.full_name + ' needs a babysitter'
    @body[:sitter] = sitter_email
    @body[:parent] = parent
    @body[:message] = message
    @body[:job] = job
  end
  
  
  def accepted_parent_connection(sender, recipient)
    content_type "text/html"
    setup_sender_info
    @recipients = recipient.email
    @subject = "SitterScout Connection Accepted!"
    @body[:recipient] = recipient
    @body[:sender] = sender

  end
  
  def accepted_sitter_connection(sender, recipient)
    content_type "text/html"
    setup_sender_info
    @recipients = recipient.email
    @subject = "SitterScout Connection Accepted!"
    @body[:recipient] = recipient
    @body[:sender] = sender
  end
  
  def accepted_sitter_connection_to_parent(sitter, accepted_user)
    content_type "text/html"
    setup_sender_info
    @recipients = sitter.consenting_parent.email
    @subject = "SitterScout Connection Accepted!"
    @body[:sitter] = sitter
    @body[:accepted_user] = accepted_user
    @body[:sender] = sitter
  end
  
  
  def job_sms_notice(sitter_email, parent, job, message=nil)
    content_type "text/html"
    setup_sender_info
    @recipients = sitter_email.profile.cell_phone.chomp("-").gsub("-", "").gsub("_", "").gsub(" ", "").gsub(".", "") + "@" + sitter_email.profile.cell_carrier.email_suffix
    @subject = "SitterScout JOB ##{job.id}"
    @body[:sitter] = sitter_email
    @body[:parent] = parent
    @body[:message] = message
    @body[:job] = job
  end
  
  def parental_consent_given(cs, sitter)
    content_type "text/html"
    setup_sender_info
    @recipients = sitter.email
    @subject = "SitterScout Minor Consent Granted"
    @body[:sitter] = sitter
    @body[:parent] = cs
  end
  
  def parental_consent_declined(cs, sitter)
    content_type "text/html"
    setup_sender_info
    @recipients = sitter.email
    @subject = "SitterScout Minor Consent Declined"
    @body[:sitter] = sitter
    @body[:parent] = cs
    
  end
  
  def underaged_job_request(sitter, parent, job, message=nil)
    content_type "text/html"
    setup_sender_info
    @recipients = sitter.consenting_parent.email
    @subject = "SitterScout Job Request"
    @body[:sitter] = sitter
    @body[:parent] = parent
    @body[:message] = message
    @body[:job] = job
  end
  
  def friend_invite(user, recipient_email, name, msg=nil)
    content_type "text/html"
    setup_sender_info
    @recipients = recipient_email
    @subject = "#{user.profile.full_name} wants you to join the SitterScout Community."
    @body[:user] = user
    @body[:recipient] = recipient_email
    @body[:message] = msg
    @body[:receiver_name] = name
  
  end
  
  def sitter_invite(user, recipient_email, name, msg=nil)
    content_type "text/html"
    setup_sender_info
    @recipients = recipient_email
    @subject = "#{user.profile.full_name} wants you to join the SitterScout Community."
    @body[:user] = user
    @body[:recipient] = recipient_email
    @body[:message] = msg
    @body[:receiver_name] = name
  end
  
  def parent_consent_request(cs, sitter)
      content_type "text/html"
      setup_sender_info
      @recipients = cs.email
      @subject = "SitterScout Minor Consent Request"
      @body[:sitter] = sitter
      @body[:parent] = cs
  end
  
  def job_filled(sitter, job)
    content_type "text/html"
    setup_sender_info
    @recipients = sitter.email
    @subject = "SitterScout Job Filled"
    @body[:sitter] = sitter
    @body[:job] = job
  end

  def job_canceled(sitter, parent, job)
    content_type "text/html"
    setup_sender_info
    @recipients = sitter.email
    @cc = parent.email
    @subject = "SitterScout Job Canceled"
    @body[:sitter] = sitter
    @body[:parent] = parent
    @body[:job] = job
  end

  def job_accepted(sitter, parent, job)
    content_type "text/html"
    setup_sender_info
    @recipients = parent.email
    @subject = "SitterScout Job Accepted!"
    @body[:sitter] = sitter
    @body[:parent] = parent
    @body[:job] = job
  end
 
  def job_declined(sitter, parent, job)
    content_type "text/html"
    setup_sender_info
    @recipients = parent.email
    @subject = "SitterScout Job Declined"
    @body[:sitter] = sitter
    @body[:parent] = parent
    @body[:job] = job
  end
  
  def system_message(recipients, subject, body)
    content_type = "text/html"
    setup_sender_info
    @recipients = recipients
    @subject = subject
    @body[:message] = body
  end
  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    setup_sender_info
    @subject     = "[#{AppConfig.community_name}]"
    @sent_on     = Time.now
    @body[:user] = user
  end

  def setup_sender_info
    @from        = "#{AppConfig.community_name}  <notifications@sitterscout.com>"  
    @headers["return_path"] = 'notifications@sitterscout.com'
  end
end
