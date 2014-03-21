require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
 	include AuthenticatedUserTestHelper	

  fixtures :users, :roles

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  
    # for testing action mailer
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @emails = ActionMailer::Base.deliveries 
    @emails.clear

  end

  def test_should_login_and_redirect
    post :login, :login => 'admin', :password => 'testing'
    assert session[:user]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :login, :login => 'admin', :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_allow_signup
    assert_difference User, :count do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference User, :count do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference User, :count do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference User, :count do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference User, :count do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_logout
    login_as :franck
    get :logout
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_activate_user
    assert_nil User.authenticate('arthur', 'arthur')
    get :activate, :id => users(:arthur).activation_code
    assert_equal "Your account has been activated.", flash[:notice]
    assert_equal users(:arthur), User.authenticate('arthur', 'arthur')
  end

  def test_should_not_activate_nil
    get :activate, :id => nil
    assert_activate_error
  end

  def test_should_not_activate_bad
    get :activate, :id => 'foobar'
    assert flash.has_key?(:error), "Flash should contain error message." 
    assert_activate_error
  end

  def assert_activate_error
    assert_response :success
    assert_template "account/activate" 
  end

  def test_should_activate_user_and_send_activation_email
    get :activate, :id => users(:arthur).activation_code
    assert_equal 1, @emails.length
  end

  def test_should_send_activation_email_after_signup
    create_user
    assert_equal 1, @emails.length
  end

  def test_should_send_reset_email_if_user_exist
    post :forgot_password, :email => "quentin@example.com"
    assert_redirected_to "account/login"
    assert_equal flash[:notice], "A password reset link has been sent to your email address"
    assert_equal 1, @emails.length
  end

  def test_should_raise_error_if_email_not_found
    post :forgot_password, :email => "error@example.com"
    assert_equal flash[:notice], "Could not find an user with that email address" 
    assert_response :success
  end
  

  protected
  def create_user(options = {})
    post :signup, :user => { :login => 'quire', :email => 'quire@example.com', 
                             :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end
