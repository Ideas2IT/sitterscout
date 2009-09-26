module ParentsHelper
  
  def auto_complete_options(users, selected=nil)
    str = "<option value ='' email='' avatar=''></option>"
    users.each do |u|
  	  str.concat("<option value ='#{u.id}' #{selected.to_i==u.id ? "selected='selected'" : ""} email='#{u.email}' avatar='#{u.avatar_photo_url}'>#{u.profile.full_name}</option>")
  	end
  	return str
  end
end