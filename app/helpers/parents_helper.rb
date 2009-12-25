module ParentsHelper
  
  def auto_complete_options(users, selected=nil)
    str = "<option value ='' email='' avatar=''></option>"
    users.each do |u|
      unless u.profile.nil?
  	   str.concat("<option value ='#{u.id}' #{selected.to_i==u.id ? "selected='selected'" : ""} email='#{u.email}' avatar='#{u.avatar_photo_url}'>#{u.profile.full_name}</option>")
      end
  	end
  	return str
  end
  
  def check_contact(user,current_user)
      friendships = user.accepted_friendships
      unless friendships.nil?
        friendships.each do |f|
          if f.friend.eql?(current_user)
            return true
          end
        end
      end
  end
  
  def rate_calc(f)
    rate_avg = f.rating_average
    if rate_avg > 5
      rate_avg = 5
    end
    half_star = 0
    return_avg = [] 
    full_star = rate_avg/1
    if full_star < 1
      full_star = 0
    else
      full_star = full_star.to_i
    end
    half_star = rate_avg%1
    if half_star != 0
      empty_star = 5 - (full_star+1)
      half_star = 1
    else
      empty_star = 5-(full_star)
      half_star = 0
    end
    rate = SitterRating.find(:all,:conditions => ['sitter_id = ?',f.id])
    
    @count=0
    rate.each do |d|
      if !d.comment.nil? and !d.comment.empty?
        @count+=1
      end
    end
    return_avg[0] = full_star
    return_avg[1] = half_star
    return_avg[2] = empty_star
    
    return return_avg
    
  end
  
   def referring_url
    if request.env["HTTP_REFERER"]
      return request.env["HTTP_REFERER"]
    else
      return "Empty"
    end
  end
 
end