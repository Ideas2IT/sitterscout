class MailProcessor < ActionMailer::Base
  
  def receive(mail)
    mail.sender
    mail.message
    
    job_id = #job id here
    acceptdecline = acceptdecline
  
    
    
    
  end
  
  
end
