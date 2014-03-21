
# Prevent double inclusion of Multibyte if running on Edge Rails
unless defined?(ActiveSupport::Multibyte)
  $:.unshift("#{File.dirname(__FILE__)}/activesupport_mb/lib")
  require "#{File.dirname(__FILE__)}/activesupport_mb/lib/active_support/multibyte"
else
  msg =  "PLUGIN DEPRECATION WARNING: unicode_hacks is not necessary 
anymore with this version of Rails. \
The plugin can be uninstalled."

  RAILS_DEFAULT_LOGGER.error(msg)
  $stderr.puts(msg)
end

require "#{File.dirname(__FILE__)}/actionpack_mb/lib/action_controller/normalization"
require "#{File.dirname(__FILE__)}/lib/actionpack_filters"
require "#{File.dirname(__FILE__)}/lib/db_unicode_client"

ActionController::Base.send(:include, UnicodeFilters::InstanceMethods)
ActionController::Base.send(:include, ActionController::Normalization)
ActionController::Base.send(:before_filter, :configure_database_charsets)
ActionController::Base.send(:after_filter, :append_charset_to_headers)
