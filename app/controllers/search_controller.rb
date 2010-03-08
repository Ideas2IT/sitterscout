class SearchController < ApplicationController
  layout 'new_design'

 def index
     @profiles = []
     @tags = ""
     if params[:searchoption] == "sitter"
      cont = 'parent_id'
      jcont ='sitter_id'
     else
      cont = 'sitter_id'
      jcont='parent_id'
    end
    if (params[:search]=~ /(\D)/) == nil
      givchar = 'number'
    end
    
    if givchar =='number'
        @profiles = Profile.paginate(:origin => params[:search], :include => [:sitter, :parent], :order => 'distance asc', :within => '15', :conditions => "#{cont.to_s} is null AND not_searchable = 1",:joins=> "INNER JOIN users ON users.id = profiles.#{jcont.to_s} AND users.active != #{true}", :per_page => 10, :page => params[:page])
        @zipcode = params[:search]
        @tags = 'Search by Zipcode'
    else
      if (params[:search]=~(/\W/)) != nil
#        flash[:notice] = "Please give only name or zipcode"
      else
        @tags = 'Search by Name'
        @profiles = Profile.paginate(:include => [:sitter, :parent],:order => 'full_name asc',:conditions => "(profiles.full_name LIKE '%#{params[:search].to_s}%' OR profiles.first_name LIKE '%#{params[:search].to_s}%' OR profiles.last_name LIKE '%#{params[:search].to_s}%')  AND profiles.#{cont.to_s} is null AND profiles.not_searchable = 1 ",:joins=> "INNER JOIN users ON users.id = profiles.#{jcont.to_s} AND users.active != #{true} ", :per_page => 10, :page => params[:page])
        @zipcode = ""
      end
    end
  
    if @profiles.empty?
      puts "its commig in profile nil condition============================================"
      @tags = 'Search by profile tag'
      @profiles = Profile.paginate_by_sql("SELECT * FROM profiles p, taggings tg, tags t WHERE p.#{jcont.to_s} IS NULL AND tg.taggable_id=p.id AND tg.tag_id = t.id AND t.name LIKE '%#{params[:search].to_s}%'", :per_page => 10, :page => params[:page])
      
    end
  
#    unless params[:parent_or_sitter]
#       begin
#        @profiles = Profile.paginate(:origin => params[:search], :order => 'distance asc', :within => '15', :conditions => "#{cont.to_s} is null AND not_searchable = 1", :per_page => 10, :page => params[:page])
#        @zipcode = params[:search]
#       rescue
#       end
#      if @profiles.length < 1
#       # @profiles = Profile.paginate_by_sql("select * from profiles where (full_name LIKE '%#{params[:search].to_s}%' OR first_name LIKE '%#{params[:search].to_s}%' OR last_name LIKE '%#{params[:search].to_s}%')  AND profiles.#{cont.to_s} is null  AND not_searchable = 1",  :per_page => 2, :page => params[:page])
#        @profiles = Profile.paginate(:conditions => "(profiles.full_name LIKE '%#{params[:search].to_s}%' OR profiles.first_name LIKE '%#{params[:search].to_s}%' OR profiles.last_name LIKE '%#{params[:search].to_s}%')  AND profiles.#{cont.to_s} is null AND profiles.not_searchable = 1", :per_page => 10, :page => params[:page])
#       
#        @zipcode = ""
#      end
#    else
#      case params[:parent_or_sitter]
#      when "Sitter"
#        @profiles = Profile.paginate(:include => :sitter, :conditions => "(profiles.full_name LIKE '%#{params[:search].to_s}%' OR profiles.first_name LIKE '%#{params[:search].to_s}%' OR profiles.last_name LIKE '%#{params[:search].to_s}%')  AND profiles.#{cont.to_s} is null AND profiles.not_searchable = 1", :per_page => 10, :page => params[:page])
#      when "Parent"
#        @profiles = Profile.paginate(:include => :parent, :conditions => "(profiles.full_name LIKE '%#{params[:search].to_s}%' OR profiles.first_name LIKE '%#{params[:search].to_s}%' OR profiles.last_name LIKE '%#{params[:search].to_s}%')  AND profiles.#{cont.to_s} is null AND profiles.not_searchable = 1", :per_page => 10, :page => params[:page])
#      when "All"
#        @profiles = Profile.paginate(:conditions => "(profiles.full_name LIKE '%#{params[:search].to_s}%' OR profiles.first_name LIKE '%#{params[:search].to_s}%' OR profiles.last_name LIKE '%#{params[:search].to_s}%')  AND profiles.#{cont.to_s} is null AND profiles.not_searchable = 1", :per_page => 10, :page => params[:page])
#      # else
#      #   @profiles = Profile.paginate(:conditions => "profiles.full_name LIKE '%#{params[:search].to_s}%' OR profiles.first_name LIKE '%#{params[:search].to_s}%' OR profiles.last_name LIKE '%#{params[:search].to_s}%' AND profiles.not_searchable = 1", :per_page => 10, :page => params[:page])        
#      end
#      @zipcode = ""
#      
#    end

     respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sitters }
     end
      # end

  end
end