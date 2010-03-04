ActionController::Routing::Routes.draw do |map|
  

  map.resources :children

  # map.resources :admin, :member => {
  #   :compose => :get,
  #   :delete_user => :post,
  #   :export_users => :get,
  #   :search => :get,
  #   :search_users => :post,
  #   :send_message => :post,
  #   :suspend_user => :post,
  #   :unsuspend_user => :post,
  #   :update_user => :post,
  #   :view_profile => :get
  # }

#  map.resources :ratings
  
#map.resources :users, :collection => {:link_user_accounts => :get}

  map.resources :parents, :collection => {:search => :post }, :member => { 
    :invite => :get,
    :welcome => :get,
    :welcome_screen => :get,
    :your_friends => :get,
    :update_friends => :post,
    :your_sitters => :get,
    :your_children => :get,
    :update_sitters => :post,
    :dashboard => :get,
    :schedule_sitter => :get,
    :sitters => :get,
    :friends => :get,
    :my_profile => :get,
    :inbox => :get,
    :search_friends => :post,
    :search_sitters => :post,
    :send_invitations => :post,
    :sitter_connection => :get,
    :parent_connection => :get,
    :invite_friends => :get,
    :login_info => :get,
    :my_photo => :get,
    :compose => :get,
    :my_children => :get,
    :update_my_children => :post,
    :update_children => :post,
    :insert_children => :post,
    :cancel_job => :post,
    :view_profile => :get,
    :view_profile_woc =>:get,
    :view_profile_search => :get,
    :view_sitter_profile => :get,
    :view_sitter_profile_woc => :get,
    :view_sitter_profile_search => :get,
    :view_profile_sitter_ac => :get,
    :view_profile_friend_ac => :get,
    :view_sitter_review => :get,
    :view_connections => :get,
    :hide_sitter_connection => :post,
    :connection_requests => :get,
    :check_availability => :post,
    :rating_sitter => :get,
    :remove_person => :post
    } do |parent|
      parent.resources :jobs
    end
    
  map.resources :profiles

  map.resources :jobs

  map.resources :zip_codes

  map.resources :friends

  map.resource :sessions, :collection => {:create_by_facebook_id=>:post}
  
  map.resources :sitters, :collection => {:search => :post }, :member => { 
    :invite => :get,
    :welcome => :get,
    :your_friends => :get,
    :your_sitters => :get,
    :dashboard => :get,
    :update_friends => :post,
    :your_requests => :get,
    :your_skills => :get,
    :welcome_screen => :get,
    :send_invitations => :post,
    :your_families => :get,
    :families => :get,
    :search_families => :post,
    :my_profile => :get,
    :my_profile_manage => :get,
    :inbox => :get,
    :compose => :get,
    :search_friends => :post,
    :friends => :get,
    :invite_friends => :get,
    :sitter_connection => :get,
    :login_info => :get,
    :my_photo => :get,
    :availability => :get,
    :create_skills => :post,
    :accept_job => :post,
    :decline_job => :post,
    :accept_job_from_email => :get,
    :decline_job_from_email => :get,
    :update_families => :post,
    :view_parent_profile => :get,
    :view_friend_profile => :get,
    :view_parent_profile_search => :get,
    :view_friend_profile_search => :get,
    :view_friend_profile_woc => :get,
    :view_parent_profile_woc => :get,
    :view_profile_family_ac => :get,
    :view_profile_friend_ac => :get,
    :view_friend_review => :get,
    :consent_sent => :get,
    :view_connections => :get,
    :connection_requests => :get,
    :skills => :get,
    :update_skills => :post,
    :rate => :post,
    :remove_person => :post
    }
    
    # map.resources :messages
 
    map.resources :users, :collection=>{:new_to_connect => :get}, :member => { 
        :dashboard => :get,
        :assume => :get,
        :toggle_moderator => :put,
        :toggle_featured => :put,
        :change_profile_photo => :put,
        :return_admin => :get, 
        :edit_account => :get,
        :update_account => :put,
        :edit_pro_details => :get,
        :update_pro_details => :put,      
        :forgot_password => [:get, :post],
        :signup_completed => :get,
        :invite => :get,
        :welcome_contact_info => :get,
        :welcome_photo => :get, 
        :welcome_about => :get, 
        :welcome_stylesheet => :get, 
        :welcome_invite => :get,
        :welcome_complete => :get,
        :statistics => :any
         } do |user|
      user.resources :friendships, :member => { :accept => :put, :deny => :put }, :collection => { :accepted => :get, :pending => :get, :denied => :get }
      user.resources :photos, :collection => {:swfupload => :post, :slideshow => :get}

      user.resources :offerings, :collection => {:replace => :put}
      user.resources :favorites, :name_prefix => 'user_'
    end
  
  map.home_page '/', :controller => 'home', :action => 'index'

  map.home '/', :controller => 'home', :action => 'index'
  
  map.how_it_works '/how_it_works', :controller => 'home', :action => "how_it_works"
  
  map.about_us '/about_us', :controller => 'home', :action => "about_us"
  
  map.invite_friends '/invite_friends', :controller => 'profiles'
  
  map.faqs '/faq', :controller => 'home', :action => 'faq'
  
  map.contact_us '/contact_us', :controller => 'home', :action => 'contact_us'
  
  map.tou '/tou', :controller=> 'home', :action => "tou"
  
  map.privacy '/privacy', :controller=> 'home', :action => "privacy"
  
  map.sitter_more '/sitter_more', :controller=> 'home', :action =>'sitter_more'
  
   map.parent_more '/parent_more', :controller=> 'home', :action =>'parent_more'
  
  # sessions routes
  
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.signup '/signup', :controller => 'users', :action => 'new'
  # map.parent_signup '/parent_signup', :controller => 'parents', :action => 'new'
  # map.sitter_signup '/sitter_signup', :controller => 'sitters', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  # Install the default routes as the lowest priority.

  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  # 
   map.comatose_admin
   map.comatose_root ''
end
