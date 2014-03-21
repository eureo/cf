require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../admin_test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  fixtures :users, :roles
  def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_should_not_raise_exception_when_accessing_admin_page
    login_as :admin
    get :index
    assert_response :success
  end
end
