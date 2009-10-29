class SearchController < ApplicationController
  layout 'new_design'

  def index
    @profiles = []
     if params[:searchoption] == 'sitter'
      cont = 'parent_id'
    else
      cont = 'sitter_id'
    end

    unless params[:parent_or_sitter]
       begin
        @profiles = Profile.paginate(:origin => params[:search], :order => 'distance asc', :within => '15', :conditions => "#{cont.to_s} is null AND not_searchable = 1", :per_page => 10, :page => params[:page])
        @zipcode = params[:search]
       rescue
       end
      if @profiles.length < 1
        @profiles = Profile.paginate_by_sql("select * from profiles where (full_name LIKE '%#{params[:search].to_s}%' OR first_name LIKE '%#{params[:search].to_s}%' OR last_name LIKE '%#{params[:search].to_s}%')  AND profiles.#{cont.to_s} is null  AND not_searchable = 1", :per_page => 10, :page => params[:page])
                puts 'rasu length'
        @zipcode = ""
      end
    else
      case params[:parent_or_sitter]
      when "Sitter"
        puts 'rasu sitter'
        @profiles = Profile.paginate(:include => :sitter, :conditions => "(profiles.full_name LIKE '%#{params[:search].to_s}%' OR profiles.first_name LIKE '%#{params[:search].to_s}%' OR profiles.last_name LIKE '%#{params[:search].to_s}%')  AND profiles.#{cont.to_s} is null AND profiles.not_searchable = 1", :per_page => 10, :page => params[:page])
      when "Parent"
        puts 'rasu parent'
        @profiles = Profile.paginate(:include => :parent, :conditions => "(profiles.full_name LIKE '%#{params[:search].to_s}%' OR profiles.first_name LIKE '%#{params[:search].to_s}%' OR profiles.last_name LIKE '%#{params[:search].to_s}%')  AND profiles.#{cont.to_s} is null AND profiles.not_searchable = 1", :per_page => 10, :page => params[:page])
      when "All"
        puts 'rasu all'
        @profiles = Profile.paginate(:conditions => "(profiles.full_name LIKE '%#{params[:search].to_s}%' OR profiles.first_name LIKE '%#{params[:search].to_s}%' OR profiles.last_name LIKE '%#{params[:search].to_s}%')  AND profiles.#{cont.to_s} is null AND profiles.not_searchable = 1", :per_page => 10, :page => params[:page])
      # else
      #   @profiles = Profile.paginate(:conditions => "profiles.full_name LIKE '%#{params[:search].to_s}%' OR profiles.first_name LIKE '%#{params[:search].to_s}%' OR profiles.last_name LIKE '%#{params[:search].to_s}%' AND profiles.not_searchable = 1", :per_page => 10, :page => params[:page])        
      end
      @zipcode = ""
      
    end


        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :xml => @sitters }
        end
      # end

  end
end