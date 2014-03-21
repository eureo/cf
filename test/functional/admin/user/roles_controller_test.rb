require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../admin_test_helper'
require 'admin/user/roles_controller'

# Re-raise errors caught by the controller.
class Admin::User::RolesController; def rescue_action(e) raise e end; end

class Admin::User::RolesControllerTest < Test::Unit::TestCase
 	include AuthenticatedUserTestHelper	

  fixtures :users, :roles, :roles_users

	def setup
    @controller = Admin::User::RolesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_new_role
		login_as :admin
		old_count = Role.count
		post :new, :role => { :title => "foo" }
		assert_equal old_count+1, Role.count
	end
	
	def test_role_title_required_on_new_role
		login_as :admin
		old_count = Role.count
		post :new, :role => { :title => nil }
    assert assigns(:role).errors.on(:title)
		assert_equal old_count, Role.count
  end

	def test_role_title_uniqueness_on_new_role
		login_as :admin
		old_count = Role.count
		post :new, :role => { :title => "admin" }
    assert assigns(:role).errors.on(:title)
		assert_equal old_count, Role.count
  end

	def test_delete_role
		login_as :admin
		old_count = Role.count
		post :delete, :id => 2
		assert_equal old_count-1, Role.count
		assert_raise(ActiveRecord::RecordNotFound) { Role.find(2) }
	end
	
end
