# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
#require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.
  
#  config.plugins = [:engines, :community_engine, :white_list, :all]
#  config.plugin_paths += ["#{RAILS_ROOT}/vendor/plugins/community_engine/engine_plugins"]

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  #config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_sitterscout_session',
    :secret      => '5b4cee8b19d01890c5b011e83d5b662c3fcf1f38fccc71bf20f809b94c984a14246e719a32a57baed670e797f227d0dc11a2ba145e720bee18f6c6881c7e1407'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :message_observer
  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  config.action_mailer.delivery_method = :sendmail
  
end

Comatose.configure do |config|
  # Includes AuthenticationSystem in the ComatoseController
  config.includes << :authenticated_system

  # admin 
  # Includes AuthenticationSystem in the ComatoseAdminController
  config.admin_includes << :authenticated_system
  
  # Calls :login_required as a before_filter
  config.admin_authorization = :login_required
  # Returns the author name (login, in this case) for the current user
  config.admin_get_author do
    current_user.login
  end
end

##Exception Notificaiton settings
ExceptionNotifier.exception_recipients = %w(heidi@sitterscout.com pkenney@pmkenney.com)

ExceptionNotifier.sender_address = %("Application Error" <app.error@sitterscout.com>)  
  
# defaults to "[ERROR] "  
  
ExceptionNotifier.email_prefix = "[SitterScout] "


##Email settings
require 'smtp_tls'



#ActionMailer::Base.delivery_method = :sendmail
# ActionMailer::Base.smtp_settings = {
#   :address => "smtp.gmail.com",
#   :port => "587",
#   :domain => "sitterscout.com",
#   :authentication => :plain,
#   :user_name => "notifications@sitterscout.com",
#   :password => "ChiefScout"
# }


#require "#{RAILS_ROOT}/vendor/plugins/community_engine/engine_config/boot.rb"
# These defaults are used in GeoKit::Mappable.distance_to and in acts_as_mappable
GeoKit::default_units = :miles
GeoKit::default_formula = :sphere

# This is the timeout value in seconds to be used for calls to the geocoder web
# services.  For no timeout at all, comment out the setting.  The timeout unit
# is in seconds. 
GeoKit::Geocoders::timeout = 3

# These settings are used if web service calls must be routed through a proxy.
# These setting can be nil if not needed, otherwise, addr and port must be 
# filled in at a minimum.  If the proxy requires authentication, the username
# and password can be provided as well.
GeoKit::Geocoders::proxy_addr = nil
GeoKit::Geocoders::proxy_port = nil
GeoKit::Geocoders::proxy_user = nil
GeoKit::Geocoders::proxy_pass = nil

# This is your yahoo application key for the Yahoo Geocoder.
# See http://developer.yahoo.com/faq/index.html#appid
# and http://developer.yahoo.com/maps/rest/V1/geocode.html
GeoKit::Geocoders::yahoo = 'lb7uk_3V34F4NXWy8Mga5J0bAfrRnXow5gUiToZi_65ajr6Aytv1NbKSxtLocc8-'
    
# This is your Google Maps geocoder key. 
# See http://www.google.com/apis/maps/signup.html
# and http://www.google.com/apis/maps/documentation/#Geocoding_Examples
GeoKit::Geocoders::google = 'ABQIAAAAL5xzbBMX1g2c9w-Py2ZsvxTgq2PCQUkPXyZUfiG1sa4Wj1449RSSaRVuYET18qoUpTTSa1_1uX0YCQ'
    
# This is your username and password for geocoder.us.
# To use the free service, the value can be set to nil or false.  For 
# usage tied to an account, the value should be set to username:password.
# See http://geocoder.us
# and http://geocoder.us/user/signup
GeoKit::Geocoders::geocoder_us = false 

# This is your authorization key for geocoder.ca.
# To use the free service, the value can be set to nil or false.  For 
# usage tied to an account, set the value to the key obtained from
# Geocoder.ca.
# See http://geocoder.ca
# and http://geocoder.ca/?register=1
GeoKit::Geocoders::geocoder_ca = false

# This is the order in which the geocoders are called in a failover scenario
# If you only want to use a single geocoder, put a single symbol in the array.
# Valid symbols are :google, :yahoo, :us, and :ca.
# Be aware that there are Terms of Use restrictions on how you can use the 
# various geocoders.  Make sure you read up on relevant Terms of Use for each
# geocoder you are going to use.
GeoKit::Geocoders::provider_order = [:yahoo, :google,:us]

module ApplicationConfiguration
  require 'ostruct'
  require 'yaml'  
  if File.exists?( File.join(RAILS_ROOT, 'config', 'application.yml') )
    file = File.join(RAILS_ROOT, 'config', 'application.yml')
    users_app_config = YAML.load_file file
  end
  default_app_config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'application.yml'))
  
  config_hash = (users_app_config||{}).reverse_merge!(default_app_config)

  ::AppConfig = OpenStruct.new config_hash
end
