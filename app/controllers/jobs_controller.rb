class JobsController < ApplicationController
  skip_before_filter :login_required
  # GET /jobs
  # GET /jobs.xml
  def index
    @jobs = Job.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.xml
  def show
    @job = Job.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @job }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.xml
  def new
    @job = Job.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job }
    end
  end

  # GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
  end

  # POST /jobs
  # POST /jobs.xml
  def create

    @job = Job.new(params[:job]) 
   
    dt_time = params[:job]["date_from(4i)"] + ":" + params[:job]["date_from(5i)"] + " " + (params[:job]["date_from(6i)"].to_i == 0 ? "AM" : "PM")
    dt = params[:parents][:scheduler] + " " + dt_time
    
    date_to = params[:job]["date_to(4i)"] + ":" + params[:job]["date_to(5i)"] + " " + (params[:job]["date_to(6i)"].to_i == 0 ? "AM" : "PM") 
    dt_to = params[:parents][:scheduler] + " " + date_to
    
    puts "#{dt}==================#{dt_to}========="
  
    puts "#{dt.to_datetime}===================#{DateTime.now}"
  
    if dt.to_datetime < DateTime.now
      flash[:error] = "#{dt.to_datetime}=======#{DateTime.now}=#{Time.now}=="
      redirect_to :back
      return  
    end
    
    if params[:sitters].blank? || params[:sitters].nil?
      flash[:error] = "Please select at least one sitter!"
      redirect_to :back
      return
    end
    
    @job.date_from = dt.to_datetime
    @job.date_to = dt_to.to_datetime
    @request_sitter = []
    @request = @job.requests.build
    @parent = Parent.find(params[:parent_id])
    
    booked_sitters = []
    params[:sitters].each do |s|
      
      j = Job.find(:all, :conditions => ["jobs.sitter_id = ? AND ((jobs.date_from between ? AND ?) OR (jobs.date_to between ? AND ?) OR (? between jobs.date_from AND jobs.date_to) OR (? between jobs.date_from AND jobs.date_to) OR (jobs.date_from = ?) OR (jobs.date_to = ?))", s, @job.date_from, @job.date_to, @job.date_from, @job.date_to, @job.date_from, @job.date_to, @job.date_from, @job.date_to])
       unless j.blank?
         j.each do |r|
           temp_request = Request.find_by_job_id(r.id)
           unless temp_request.nil?
             temp2 = RequestSitter.find_by_sql("SELECT state AS status FROM request_sitters WHERE request_id = '#{temp_request.id}'")[0]
             if temp2.status == 'accepted'
               booked_sitters << s
            end
          end
        end
      end
    end
    
    unless booked_sitters.blank?
      session[:booked_sitters] = booked_sitters
      flash[:error] = "At least one of your sitters is booked during that time."
      redirect_to :back
      return
    end
    
    @job.parent = @parent
      if @job.save && @request.save
        params[:sitters].each do |s|
          @request_sitter << RequestSitter.create(:sitter => Sitter.find(s), :request => @request)      
          Notifications.deliver_job_notice(Sitter.find(s), current_user, @job ,params[:message][:message]) if (Sitter.find(s).profile.email == true)
          Notifications.deliver_job_sms_notice(Sitter.find(s), current_user, @job ,params[:message][:message]) if (Sitter.find(s).profile.text_message == true)
          if (Sitter.find(s).underage?)
            if Sitter.find(s).consenting_parent.notify_parent_request  
              Notifications.deliver_underaged_job_request(Sitter.find(s), current_user, @job, params[:message][:message]) 
            end
          end
        end    
        redirect_back_or_default(dashboard_parent_path(current_user))
        flash[:notice] = 'Job was successfully created.'
      else
       render :action => "new" 
   end
   
   rescue 
    flash[:error]= "Please select at least one sitter!"
    redirect_to :back
 
  end

  # PUT /jobs/1
  # PUT /jobs/1.xml
  def update
    @job = Job.find(params[:id])

    respond_to do |format|
      if @job.update_attributes(params[:job])
        flash[:notice] = 'Job was successfully updated.'
        #flash.discard
        format.html { redirect_to(@job) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.xml
  def destroy
    @job = Job.find(params[:id])
    @job.destroy

    respond_to do |format|
      format.html { redirect_to(jobs_url) }
      format.xml  { head :ok }
    end
  end
end
