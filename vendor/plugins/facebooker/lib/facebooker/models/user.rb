require 'facebooker/model'
require 'facebooker/models/affiliation'
require 'facebooker/models/work_info'

module Facebooker
  # 
  # Holds attributes and behavior for a Facebook User
  class User
    include Model
    class Status
      include Model
      attr_accessor :message, :time
    end
    
    FIELDS = [:status, :political, :pic_small, :name, :quotes, :is_app_user, :tv, :profile_update_time, :meeting_sex, :hs_info, :timezone, :relationship_status, :hometown_location, :about_me, :wall_count, :significant_other_id, :pic_big, :music, :uid, :work_history, :sex, :religion, :notes_count, :activities, :pic_square, :movies, :has_added_app, :education_history, :birthday, :first_name, :meeting_for, :last_name, :interests, :current_location, :pic, :books, :affiliations]
    attr_accessor :id, :session
    attr_reader :affiliations
    populating_attr_accessor *FIELDS
    populating_hash_settable_accessor :current_location, Location
    populating_hash_settable_accessor :hometown_location, Location
    populating_hash_settable_accessor :hs_info, EducationInfo::HighschoolInfo
    populating_hash_settable_accessor :status, Status
    populating_hash_settable_list_accessor :affiliations, Affiliation
    populating_hash_settable_list_accessor :education_history, EducationInfo
    populating_hash_settable_list_accessor :work_history, WorkInfo
    
    # Can pass in these two forms:
    # id, session, (optional) attribute_hash
    # attribute_hash
    def initialize(*args)
      if (args.first.kind_of?(String) || args.first.kind_of?(Integer)) && args.size==1
        @id=Integer(args.shift)
        @session = Session.current
      elsif (args.first.kind_of?(String) || args.first.kind_of?(Integer)) && args[1].kind_of?(Session)
        @id = Integer(args.shift)
        @session = args.shift
      end
      if args.last.kind_of?(Hash)
        populate_from_hash!(args.pop)
      end      
    end
    
    # Returns a user's events, params correspond to API call parameters (except UID):
    # http://wiki.developers.facebook.com/index.php/Events.get
    # E.g:
    #  @user.events(:start_time => Time.now.to_i, :end_time => 1.month.from_now.to_i)
    #  # => Returns events betwen now and a month from now
    def events(params={})
      @events ||= @session.post('facebook.events.get', {:uid => self.id}.merge(params)).map do |event|
        Event.from_hash(event)
      end
    end
    
    # 
    # Set the list of friends, given an array of User objects.  If the list has been retrieved previously, will not set
    def friends=(list_of_friends)
      @friends ||= list_of_friends
    end
    
    ##
    # Retrieve friends
    def friends
      @friends ||= @session.post('facebook.friends.get').map do |uid|
        User.new(uid, @session)
      end
    end
    
    ###
    # Retrieve friends with user info populated
    # Subsequent calls will be retrieved from memory.
    # Optional: list of fields to retrieve as symbols
    def friends!(*fields)
      @friends ||= session.post('facebook.users.getInfo', :fields => collect(fields), :uids => friends.map{|f| f.id}.join(',')).map do |hash|  
        User.new(hash['uid'], session, hash)
      end
    end
    
    ###
    # Retrieve profile data for logged in user
    # Optional: list of fields to retrieve as symbols
    def populate(*fields)
      session.post('facebook.users.getInfo', :fields => collect(fields), :uids => id) do |response|
        populate_from_hash!(response.first)
      end
    end
        
    def friends_with?(user_or_id)
      friends.map{|f| f.to_i}.include?(user_or_id.to_i)  
    end
    
    def friends_with_this_app
      @friends_with_this_app ||= session.post('facebook.friends.getAppUsers').map do |uid|
        User.new(uid, session)
      end
    end
    
    def groups(gids = [])
      args = gids.empty? ? {} : {:gids => gids}
      @groups ||= session.post('facebook.groups.get', args).map do |hash|
        group = Group.from_hash(hash)
        group.session = session
        group
      end
    end
    
    def notifications
      @notifications ||= Notifications.from_hash(session.post('facebook.notifications.get'))
    end
    
    def publish_story(story)
      publish(story)
    end
    
    def publish_action(action)
      publish(action)
    end
    
    def publish_templatized_action(action)
      publish(action)
    end
    
    def albums
      @albums ||= session.post('facebook.photos.getAlbums', :uid => self.id) do |response|
        response.map do |hash|
          Album.from_hash(hash)
        end
      end
    end
    
    def create_album(params)
      @album = session.post('facebook.photos.createAlbum', params) {|response| Album.from_hash(response)}
    end
    
    def profile_photos
      session.get_photos(nil, nil, profile_pic_album_id)
    end
    
    def upload_photo(multipart_post_file)
      Photo.from_hash(session.post_file('facebook.photos.upload', {nil => multipart_post_file}))
    end
    
    def profile_fbml
      session.post('facebook.profile.getFBML', :uid => @id)  
    end    
    
    ##
    # Set the profile FBML for this user
    #
    # This does not set profile actions, that should be done with profile_action=
    def profile_fbml=(markup)
      set_profile_fbml(markup, nil, nil)
    end
    
    ##
    # Set the mobile profile FBML
    def mobile_fbml=(markup)
      set_profile_fbml(nil, markup, nil)
    end
    
    ##
    # Set profile actions
    def profile_action=(markup)
      set_profile_fbml(nil, nil, markup)
    end
    
    ## *** NEW PROFILE DESIGN ***
    # Set main profile FBML
    def profile_main_fbml=(markup)
      set_profile_fbml(nil, nil, nil, markup)
    end
    
    ##
    # Set all profile FBML items
    def set_profile_fbml(profile_fbml, mobile_fbml, profile_action_fbml, profile_main)
      parameters = {:uid => @id}
      parameters[:profile] = profile_fbml if profile_fbml
      parameters[:profile_action] = profile_action_fbml if profile_action_fbml
      parameters[:mobile_profile] = mobile_fbml if mobile_fbml
      parameters[:profile_main] = profile_main if profile_main
      session.post('facebook.profile.setFBML', parameters)
    end
    
    ## ** NEW PROFILE DESIGN ***
    # Set a info section for this user
    #
    # info_fields should be an array of Facebooker::InfoField objects.
    # Facebooker::InfoField should contain an array of Facebooker::InfoItem objects.
    #
    # Example:
    # fields = [
    #   Facebooker::InfoField.new(:field => "First Field", :items => [
    #     Facebooker::InfoItem.new(:label => "first item", :link => "http://first_link.com"), 
    #     Facebooker::InfoItem.new(:label => "second_item", :link => "http://second_link.com") 
    #   ] ),
    #   Facebooker::InfoField.new(:field => "Second Field", :items => [
    #     Facebooker::InfoItem.new(:label => "a new item", :link => "http://foo.bar"),
    #     Facebooker::InfoItem.new(:label => "another item", :link => "http://blog.dnite.org"),
    #     Facebooker::InfoItem.new(:label => "one more item", :link => "http://yaaaay.com")
    #   ] )
    # ]
    # facebook_session.user.set_profile_info("Section Title", fields)
    def set_profile_info(title, info_fields, format = :text)
      session.post('facebook.profile.setInfo', :title => title, :uid => @id, 
        :type => format.to_s == "text" ? 1 : 5, :info_fields => info_fields.to_json)
    end
    
    # *** NEW PROFILE DESIGN ***
    # This populates the user object with their profile info section.
    # The info section consists of an InfoField object which contains InfoItem objects.
    def profile_info
      @profile_info ||= @session.post('facebook.profile.getInfo', :uid => self.id) do |section|
        InfoSection.from_hash(section)
      end
    end
    
    
    ##
    # Set the status of the user
    #
    # DOES NOT prepend "is" to the message
    #
    # requires extended permission. 
    def status=(message)
      case message
      when String
        session.post('facebook.users.setStatus',:status=>message,:status_includes_verb=>1) do |ret|
          ret
        end
      when Status
        @status = message
      when Hash
        @status = Status.from_hash(message)
      end
    end
    
    ##
    # Convenience method to send email to the current user
    def send_email(subject, text=nil, fbml=nil)
      session.send_email([@id], subject, text, fbml)
    end
    
    ##
    # Convenience method to set cookie for the current user
    def set_cookie(name, value, expires=nil, path=nil)
      session.data.set_cookie(@id, name, value, expires, path)
    end
    
    ##
    # Convenience method to get cookies for the current user
    def get_cookies(name=nil)
      session.data.get_cookies(@id, name)
    end
    
    ##
    # Returns the user's id as an integer
    def to_i
      id
    end
    
    def to_s
      id.to_s
    end
    
    def self.cast_to_facebook_id(object)
      if object.respond_to?(:facebook_id)
        object.facebook_id
      else
        object
      end
    end
    
    private
    def publish(feed_story_or_action)
      session.post(Facebooker::Feed::METHODS[feed_story_or_action.class.name.split(/::/).last], feed_story_or_action.to_params) == "1" ? true : false
    end
    
    def collect(fields)
      FIELDS.reject{|field_name| !fields.empty? && !fields.include?(field_name)}.join(',')
    end
    
    def profile_pic_album_id
      merge_aid(-3, @id)
    end
    
    def merge_aid(aid, uid)
      (uid << 32) + (aid & 0xFFFFFFFF)
    end
    
  end
end
