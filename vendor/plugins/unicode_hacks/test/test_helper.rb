$KCODE = 'u' # YES please, thank you.
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
require 'rubygems'

require 'active_support'
require 'action_pack'
require 'active_record'
require 'action_controller'
require 'action_controller/test_process'
ActionController::Base.logger = nil
ActionController::Base.ignore_missing_templates = false
ActionController::Routing::Routes.reload rescue nil

RAILS_DEFAULT_LOGGER = Logger.new($stderr)

require File.dirname(__FILE__)  + "/../init"

class Test::Unit::TestCase
  private
    def with_kcode(kcode)
      old_kc = $KCODE
      begin
        $KCODE = kcode
        yield
      ensure
        $KCODE = old_kc
      end
    end
end
