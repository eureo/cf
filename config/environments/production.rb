# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false
  
# session store
config.action_controller.session_store = :active_record_store

# memcache configuration
require 'memcache'
memcache_options = {
  :c_threshold => 10_000,
  :compression => false,
  :debug => false,
  :namespace => 'ce_production',
  :readonly => false,
  :urlencode => false
}

CACHE = MemCache.new memcache_options
CACHE.servers = 'localhost:11211'

ActionController::Base.session_options[:cache] = CACHE

# ActionMailer Settings
#ActionMailer::Base.delivery_method = :activerecord
ActionMailer::Base.delivery_method = :sendmail
#ActionMailer::Base.delivery_method = :smtp
#ActionMailer::Base.smtp_settings = {
#  :address        => "mail.connexion-emploi.dreamhosters.com",
#  :port           => 587,
#  :domain         => "connexion-emploi.dreamhosters.com",
#  :authentication => :login,
#  :user_name      => "m4987465",
#  :password       => "feiduno"
#}
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_charset = "utf-8"