require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../admin_test_helper'
require 'admin/cms/categories_controller'

# Re-raise errors caught by the controller.
class Admin::Cms::CategoriesController; def rescue_action(e) raise e end; end

class Admin::Cms::CategoriesControllerTest < Test::Unit::TestCase
	fixtures :users, :roles, :roles_users, :categories

  def setup
    @controller = Admin::Cms::CategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

	def test_index
		login_as :cms_user
		get :index
		assert_response :success
	end

	def test_new
		login_as :olivier
		old_count = Category.count
		post :new, :category => {:name => "offres", :parent_id => 2 }
		assert_equal "Category was successfully created.", flash[:notice]
		assert_equal old_count+1, Category.count
		assert_redirected_to 'admin/cms/pages/index'
	end

	def test_title_required_on_new_category
		login_as :olivier
		old_count = Category.count
		post :new, :category => {:name => nil, :parent_id => 2 }
		assert_equal old_count, Category.count
		assert_response :success
	end

	def test_title_required_on_edit_category
		login_as :olivier
		old_count = Category.count
		post :edit, :id => 2, :category => {:name => nil, :parent_id => 2 }
		assert_equal old_count, Category.count
    assert assigns(:category).errors.on(:name)
		assert_response :success
	end

	def test_edit
		login_as :olivier
		post :edit, :id => 2, :category => { :name => "offres", :parent_id => "4" }
		assert_equal "Category was successfully updated.", flash[:notice]
		assert_redirected_to 'admin/cms/categories/list'
	end

	# this test works only if deleted category has only leaves subcategories
	# it is the case for "economie" in our fixtures
	def test_delete
		login_as :olivier
		old_count = Category.count
		economie_children_count = categories(:info_pratiques).children.count
		post :delete, :id => categories(:info_pratiques).id
		assert_equal old_count-economie_children_count-1, Category.count
		assert_equal "Category was successfully deleted.", flash[:notice]
		assert_redirected_to 'admin/cms/categories/list'
	end

  def test_delete_should_also_delete_articles
		login_as :olivier
  end
	
end
