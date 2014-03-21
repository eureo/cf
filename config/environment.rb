# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.2'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )
  config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache/"
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

$KCODE = 'u'
require 'jcode'

# LOCALIZATION
require 'environments/localization_settings_environment'
require 'localization_settings'
LocalizationSettings::load_localized_strings

# add method to calculate age from a birth date
require 'Date'
# custom Date format
my_formats = {
  :cv_format => '%m-%Y',
  :full_date  => '%d/%m/%Y',
  :eu_format  => '%d/%m/%Y'
}
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(my_formats)
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(my_formats)

# Extend of String Class : to_url method added
require 'transforms.rb'

# GOOGLE ANALYTICS
Rubaidh::GoogleAnalytics.tracker_id = 'UA-327683-4'

# Set the default place to find file_column files.
FILE_COLUMN_PREFIX = 'files'
module FileColumn
	module ClassMethods
		DEFAULT_OPTIONS[:root_path] = File.join(RAILS_ROOT, "public", FILE_COLUMN_PREFIX)
		DEFAULT_OPTIONS[:web_root] = "#{FILE_COLUMN_PREFIX}/"
	end
end

# Exception Notification setup
#ExceptionNotifier.exception_recipients = %w(franck.dagostini@gmail.com)
#ExceptionNotifier.email_prefix = "[CF] "

ActionController::Base.session_options[:session_key] = 'cf_session_id'
ActionController::Base.session_options[:session_expires] = 2.months.from_now

require 'hominid'
MAILCHIMP_API_KEY = "bba51db994dd4ae8c550ffa0388e85e6-us2"
if RAILS_ENV == 'production'
  MAILCHIMP_LIST_ID = "bffde8ee7e"
else
  MAILCHIMP_LIST_ID = "bffde8ee7e"
end