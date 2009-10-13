class Profile < ActiveRecord::Base
  searchable_by :first_name, :last_name

  belongs_to :sitter, :with_deleted => true
  belongs_to :parent, :with_deleted => true
  belongs_to :state
  belongs_to :cell_carrier
  before_save :set_full_name
    
  validates_presence_of :lat, :lng
  validates_presence_of :address1, :message => "^Please enter a valid address."
  validates_presence_of :last_name, :message => "^Last name cannot be blank."
  validates_presence_of :first_name, :message => "^First name cannot be blank."
  validates_presence_of :zipcode, :message => "^Zipcode cannot be blank."

  acts_as_taggable
  acts_as_mappable #:auto_geocode => true
  
  before_validation :set_address
  

  
  AVAILABILITY = ["", "Mornings", "Afternoons", "Nights", "All Day"]

  
  def percentage_complete
    percentage = 20
    
    case self.parent?
    when true
      unless self.city.nil?
        percentage += 20
      end
      unless self.parent.children.count < 1
        percentage += 20
      end
      if self.not_searchable
        percentage += 20        
      end
      if self.parent.photo
        percentage += 20
      end
      
    when false
       unless self.city.nil?
          percentage += 20
       end
        if self.sitter.skill
          percentage += 20
        end
        if self.sitter.photo
          percentage += 20
        end
        if self.not_searchable
           percentage += 20        
         end
    end
    
    return percentage
  end
  
  
  def self.tagged_with_and_parent(t)
      p = self.find_tagged_with(t)
      ret = []
  
      p.each do |t|
        if t.parent?
          ret << t
        end
      end
    ret
  end

  def self.tagged_with_and_sitter(t)
      p = self.find_tagged_with(t)
      ret = []

      p.each do |t|
        if t.sitter?
          ret << t
        end
      end
    ret
  end
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  
  def sitter_display_name
    "#{self.first_name} #{truncate(self.last_name, 2, '.')}"
  end
  
  def profile_email
    begin
      case self.parent?
      when true
        unless self.parent.nil?
          return self.parent.email.squeeze(' ')
        end
      when false
        unless self.sitter.nil?
          return self.sitter.email.squeeze(' ')
        end
      end
   rescue
     nil
   end
  end
  
  def self.distance_search(zip=nil)
    find(:all, :origin => zip, :order => 'distance asc', :within => '15', :conditions => "not_searchable = 1")
  end
  
  
  def self.parents_you_may_know(uid)
    begin
    ret_array = []
    ret = find(:all, :conditions => ["not_searchable = ? AND parent_id <> ? AND parent_id IS NOT NULL", true, uid ],:origin => "#{uid.zipcode.to_s}", :within=>10, :order=>'distance asc')
    ret2 = find(:all, :conditions => ["not_searchable = ? AND parent_id <> ? AND parent_id IS NOT NULL", true, uid ],:origin => "#{uid.zipcode.to_s}", :order => 'distance asc')
    ret_a = ret.concat(ret2)
    
    old_ids = []
    ret_a.uniq.each do |ra|
      if ra.id != uid.id
        #ret_array << Parent.find(ra.parent_id) rescue nil
        old_ids << ra.parent_id
      end
    end
    
    puts "old ids #{old_ids.uniq.sort}"
    
    my_ret_a = []
    ret_a.uniq.each do |ra|
      if ra.id != uid.id
        my_ret_a << ra.parent_id
      end
    end
    
    puts "my ids #{my_ret_a.uniq.sort}"
    
    my_ret_array = Parent.find(:all, :include => [:photo], :conditions => ["users.id in (?) ", my_ret_a])
    
    
    puts "old recs #{ret_array.collect(&:id).uniq.sort}"
    puts "my recs #{my_ret_array.collect(&:id).uniq.sort}"
    
    rescue GeoKit::Geocoders::GeocodeError => ex
      ret_array = []
      ret = find(:all, :conditions => ["not_searchable = ? AND parent_id <> ? AND parent_id IS NOT NULL", true, uid ])
      ret.uniq.each do |ra|
        if ra.id != uid.id
          ret_array << Parent.find(ra.parent_id) rescue nil
        end
      end
    end
    
    return my_ret_array
  end
  
  def self.sitters_you_may_know(uid)
    begin
      ret_array = []
      ret = find(:all, :conditions => ["not_searchable = ? AND sitter_id <> ? AND sitter_id IS NOT NULL", true, uid ],:origin => "#{uid.zipcode.to_s}", :within=>10, :order=>'distance asc')
      ret2 = find(:all, :conditions => ["not_searchable = ? AND sitter_id <> ? AND sitter_id IS NOT NULL", true, uid ],:origin => "#{uid.zipcode.to_s}", :order => 'distance asc')
      ret_a = ret.concat(ret2)
      
      my_ret_a = []
      ret_a.uniq.each do |ra|
        if ra.id != uid.id
          my_ret_a << ra.sitter_id
        end
      end
      
      my_ret_array = Sitter.find(:all, :include => [:photo], :conditions => ["users.id in (?) ", my_ret_a])
      
    rescue GeoKit::Geocoders::GeocodeError => ex
      ret_array = []
      ret = find(:all, :conditions => ["not_searchable = ? AND sitter_id <> ? AND sitter_id IS NOT NULL", true, uid ])
      ret.uniq.each do |ra|
        ret_array << Sitter.find(ra.sitter_id) rescue nil
      end
    end
    
    return my_ret_array
  end
   
  def sitter?
    self.parent_id.nil?
  end
  
  def parent?
    self.sitter_id.nil?
  end
  
  private
  
  #set this for geocoding searches
  def set_address
    begin
      self.address = self.address1 + ", " + self.city + ", " + State.find(self.state_id).name + " " + self.zipcode.to_s

      geo=GeoKit::Geocoders::MultiGeocoder.geocode(self.address)
      
      if !geo.success
        geo=GeoKit::Geocoders::MultiGeocoder.geocode(self.zipcode.to_s)    
        errors.add(:address, "^Could not Geocode address") if !geo.success
      end
      self.lat, self.lng = geo.lat,geo.lng if geo.success
    rescue
    end
  end
  
  def set_full_name
    self.full_name = first_name + " " + last_name
  end

end
