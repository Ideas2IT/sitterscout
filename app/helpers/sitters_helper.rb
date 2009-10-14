module SittersHelper
  def auto_complete_options(users, selected=nil)
      str = "<option value ='' email='' avatar=''></option>"
      users.each do |u|
    	  str.concat("<option value ='#{u.id}' #{selected.to_i==u.id ? "selected='selected'" : ""} email='#{u.email}' avatar='#{u.avatar_photo_url}'>#{u.profile.full_name}</option>")
    	end
    	return str
 end
 
 def referring_url
    if request.env["HTTP_REFERER"]
      return request.env["HTTP_REFERER"]
    else
      return "Empty"
    end
  end
 
end