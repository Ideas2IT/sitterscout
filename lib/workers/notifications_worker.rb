class NotificationsWorker < BackgrounDRb::MetaWorker

  set_worker_name :notifications_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    add_periodic_timer(3600) { 
#    send_notifications
#     puts "this is called jobs======================="
     sitter_request_remainder
     sitter_rating
    }
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
    
    
    #job remainder email
    def sitter_request_remainder
#    puts "puts remainder====================="
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
  
  #rating notification email
  
  def sitter_rating
#    puts "calling====rating================"
    rate_to_send = Job.find(:all, :conditions => ["? >= (date_to + INTERVAL 12 HOUR) AND rate_notification IS NOT TRUE",Time.now])
      
    rate_to_send.each do |rate|
         unless rate.parent.nil?
#            puts "parent=================="
            unless rate.sitter.nil?
#                puts "sitter================="
                parent = Parent.find(rate.parent_id)
                sitter = Sitter.find(rate.sitter_id)
                if parent.profile.email?
                      Notifications.deliver_parent_job_rating_poll(parent, sitter, rate)
#                     puts "called from this email========================="
                end
            end 
          end
    end
    
    r.rate_notification = true
    r.save
    
   end
  
end #notifications

