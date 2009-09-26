class SendNotifications < ActiveRecord::Base
  
  jobs_to_send = Job.find(:all, :conditions => ["date_from <= ? AND notification_sent IS NOT true", 2.days.from_now])
  
  jobs_to_send.each do |j|
    unless j.parent_id.nil? || j.sitter_id.nil? || (j.status == 'cancelled')
    parent = Parent.find(j.parent_id)
    sitter = Sitter.find(j.sitter_id)
    
    if parent.profile.text_message
      #Notifications.deliver_parent_job_sms_reminder(parent, sitter, j)  
    end
    
    if parent.profile.email
      Notifications.deliver_parent_job_reminder(parent, sitter, j)
    end
    
    if sitter.profile.text_message
      #Notifications.deliver_sitter_job_sms_reminder(parent, sitter, j)
      
    end
    
    if sitter.profile.email
      Notifications.deliver_sitter_job_reminder(parent, sitter, j)
    end
    
    j.notification_sent = true
    j.save
    end
  end
  
  
end