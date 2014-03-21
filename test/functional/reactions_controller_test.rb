require File.dirname(__FILE__) + '/../test_helper'
require 'reactions_controller'

# Re-raise errors caught by the controller.
class ReactionsController; def rescue_action(e) raise e end; end

class ReactionsControllerTest < Test::Unit::TestCase
  def setup
    @controller = ReactionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
