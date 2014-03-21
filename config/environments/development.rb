# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Enable the breakpoint server that script/breakpointer connects to
config.breakpoint_server = true

# Show full error reports and perform caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true
config.action_view.cache_template_extensions         = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

# ActionMailer Settings
ActionMailer::Base.delivery_method = :sendmail
# ActionMailer::Base.delivery_method = :smtp
# ActionMailer::Base.smtp_settings = {
#   :address        => "mail.connexion-emploi.dreamhosters.com",
#   :port           => 587,
#   :domain         => "connexion-emploi.dreamhosters.com",
#   :authentication => :login,
#   :user_name      => "m4987465",
#   :password       => "feiduno"
# }
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_charset = "utf-8"

config.log_level = :debug