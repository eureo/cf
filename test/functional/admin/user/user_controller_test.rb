require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../admin_test_helper'
require 'admin/user/user_controller'

# Re-raise errors caught by the controller.
class Admin::User::UserController; def rescue_action(e) raise e end; end

class Admin::User::UserControllerTest < Test::Unit::TestCase

  fixtures :users, :roles

  def setup
    @controller = Admin::User::UserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

	def test_login_required_on_edit_user
		login_as :admin
		admin_modify_user(:login => nil) #admin only
    assert assigns(:user).errors.on(:login)
    assert_response :success
	end

	def test_password_required_on_edit_user
		login_as :admin
		admin_modify_user(:password => nil) #admin only
    assert assigns(:user).errors.on(:password)
    assert_response :success
	end
		
	def test_password_confirmation_required_on_edit_user
		login_as :admin
		admin_modify_user(:password_confirmation => nil) #admin only
    assert assigns(:user).errors.on(:password_confirmation)
    assert_response :success
	end
		
	def test_email_required_on_edit_user
		login_as :admin
		admin_modify_user(:email => nil) #admin only
    assert assigns(:user).errors.on(:email)
    assert_response :success
	end

	def test_assign_user_role_on_edit
		login_as :admin
		post :edit_user_roles, { :id => 6, :roles => [ roles(:user).id ]}
		assert User.find(6).roles.detect{|role| role.title == roles(:user).title }
		assert_equal "User's role was updated", flash[:notice]
		assert_redirected_to :action => :list
	end
	
	def test_assign_user_and_admin_roles_on_edit
		login_as :admin
		post :edit_user_roles, { :id => 6, :roles => ["1","2"]}
		assert User.find(6).roles.detect{|role| role.title == "user"}
		assert User.find(6).roles.detect{|role| role.title == "admin"}
		assert_equal "User's role was updated", flash[:notice]
		assert_redirected_to :action => :list
	end

	def test_assign_no_roles_on_edit
		login_as :admin
		post :edit_user_roles, { :id => 6, :roles => []}
		assert_nil User.find(6).roles.detect{|role| role.title == "user"}
		assert_equal "User's role was updated", flash[:notice]
		assert_redirected_to :action => :list
	end

	def test_delete_user
		login_as :admin
    old_count = User.count
		post :delete, :id => 6
		assert_equal old_count-1, User.count
		assert_raise(ActiveRecord::RecordNotFound) { User.find(6) }
		assert_response :redirect
	end

	def test_login_required_on_new_user
		login_as :admin
    old_count = User.count
    new_user(:login => nil)
    assert assigns(:user).errors.on(:login)
    assert_response :success
    assert_equal old_count, User.count
	end

	def test_password_required_on_new_user
		login_as :admin
    old_count = User.count
    new_user(:password => nil)
    assert assigns(:user).errors.on(:password)
    assert_response :success
    assert_equal old_count, User.count
	end

	def test_password_confirmation_required_on_new_user
		login_as :admin
    old_count = User.count
    new_user(:password_confirmation => nil)
    assert assigns(:user).errors.on(:password_confirmation)
    assert_response :success
    assert_equal old_count, User.count
	end

	def test_email_required_on_new_user
		login_as :admin
    old_count = User.count
    new_user(:email => nil)
    assert assigns(:user).errors.on(:email)
    assert_response :success
    assert_equal old_count, User.count
	end
	
  protected
  def new_user(options = {})
    post :new, :user => { :login => 'olivier', :email => 'olivier@connexion-francaise.com', 
                             :password => 'atest', :password_confirmation => 'atest' }.merge(options)
  end

	def admin_modify_user(options = {})
    post :edit, { :id => 6 ,:user => { :email => 'franck@example.com', :login => 'franck',
											:password => 'newpassword', :password_confirmation => 'newpassword' }.merge(options)}
	end		


	
end
