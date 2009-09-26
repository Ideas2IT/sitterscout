class NotificationsWorker < BackgrounDRb::MetaWorker
  set_worker_name :notifications_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    add_periodic_timer(10) { send_notifications }
    
  end
  
  def send_notifications
    j = Job.find(:all, :conditions => ["status = ?", "accepted"])
      j.each do |job|
       # # if job.date_from.to_date < Time.now.to_date
       #    if Sitter.find(job.sitter_id).profile.email
       #      Notifications.deliver_sitter_job_reminder(Parent.find(job.parent_id), Sitter.find(job.sitter_id), job)
       #  
       #    end
       #    if Sitter.find(job.sitter_id).profile.text_message
       #      #Notifications.deliver_sitter_job_sms_reminder(Parent.find(job.parent_id), Sitter.find(job.sitter_id), job)
       #    end
       #       
        #  if Parent.find(job.parent_id).profile.email
            Notifications.deliver_parent_job_reminder(Parent.find(job.parent_id), Sitter.find(job.sitter_id), job)
        
          #end
         # if Parent.find(job.parent_id).profile.text_message
            #Notifications.deliver_parent_job_sms_reminder(Parent.find(job.parent_id), Sitter.find(job.sitter_id), job)
          #end#Parent.find
        #end#job.date
      end#j.each
    end#j=job
  
end#notifications

