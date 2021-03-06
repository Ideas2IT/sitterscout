class RatingsController < ApplicationController
  
  before_filter :login_required
  
  def create
    
      @rating = SitterRating.new(params[:rating])
      @rating.parent  = current_user
      @sitter = Sitter.find(params[:sitter_id])
      @rating.sitter = @sitter
      if @rating.save
        flash[:notice] = "Thank you for submitting your rating."
      end
                 
      sitter_no = SitterRating.find(:all,:conditions => ['sitter_id = ?',params[:sitter_id]])
      sum = @rating.my_request + @rating.arr_time + @rating.asked + @rating.condition + @rating.my_child
      rating = User.find_by_id(params[:sitter_id])

      unless sitter_no.size.nil?
        if rating.rating_average <= 0.0 
            calc = (sum / 20.0)*5.0.to_f
        else
            calc = (sum / 20.0)*5.0.to_f
            calc = (calc + rating.rating_average) / sitter_no.size
        end
      end 
      rating.rating_average = calc
      rating.save
      
      redirect_to dashboard_parent_path(current_user)
  end
  
end
