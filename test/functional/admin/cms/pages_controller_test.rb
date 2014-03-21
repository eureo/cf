require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../admin_test_helper'
require 'admin/cms/pages_controller'

# Re-raise errors caught by the controller.
class Admin::Cms::PagesController; def rescue_action(e) raise e end; end

class Admin::Cms::PagesControllerTest < Test::Unit::TestCase
	fixtures :users, :roles, :roles_users, :categories, :articles

  def setup
    @controller = Admin::Cms::PagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    login_as :cms_user
		get :index
		assert_response :success
  end

	def test_new
		login_as :cms_user
		old_count = Article.count
		post :new, :article => { :title => "Un article", :author => "Franck", :excerpt => "un excerpt", :body => "un corps" }
		assert_equal "Your article was created.", flash[:notice]
		assert_response :redirect
		assert_equal old_count+1, Article.count
	end

	def test_new_should_have_title
		login_as :cms_user
		old_count = Article.count
		post :new, :article => { :title => nil, :author => "Franck", :excerpt => "un excerpt", :body => "un corps" }
		assert_response :success
		assert assigns(:article).errors.on(:title)
		assert_equal old_count, Article.count
	end

	def test_edit_only_admin_if_article_published
		login_as :olivier
		post :edit, :id => articles(:premier_article).id, :article => { :title => "Un article modifié", :author => "Franck", :excerpt => "un excerpt", :body => "un corps" }
		assert_equal 'Article was successfully updated.', flash[:notice]
		assert_response :redirect
	end

	def test_edit_should_have_title
		login_as :olivier
		post :edit, :id => articles(:premier_article).id, :article => { :title => nil, :author => "Franck", :excerpt => "un excerpt", :body => "un corps" }
		assert_response :success
		assert assigns(:article).errors.on(:title)
	end

	def test_delete
		login_as :olivier
		old_count = Article.count
		post :delete, :id => articles(:premier_article).id
		assert_equal 'Article was successfully deleted.', flash[:notice]
		assert_equal old_count-1, Article.count
		assert_response :redirect
	end

	def test_publish
		login_as :olivier
		post :publish, :id => articles(:premier_article).id
		assert_equal 'Article was successfully published.', flash[:notice]
		assert articles(:premier_article).published
		assert !articles(:premier_article).archived
		assert_response :redirect
	end

	def test_unpublish
		login_as :olivier
		post :unpublish, :id => articles(:premier_article).id
		assert_equal 'Article was successfully unpublished.', flash[:notice]
		article = articles(:premier_article).reload
		assert !article.published
		assert_response :redirect
	end

	def test_archive
		login_as :olivier
		post :archive, :id => articles(:premier_article).id
		assert_equal 'Article was successfully archived and unpublished.', flash[:notice]
		article = articles(:premier_article).reload
		assert !article.published
		assert article.archived
		assert_response :redirect
	end

	def test_unarchive
		login_as :olivier
		post :unarchive, :id => 1
		assert_equal 'Article was successfully unarchived.', flash[:notice]
		assert !articles(:premier_article).archived
		assert_response :redirect
	end

	def test_upload_image
		login_as :cms_user
	end

	def test_delete_image
		login_as :cms_user
	end

	def test_upload_attachment
		login_as :cms_user
	end

	def test_delete_attachment
		login_as :cms_user
	end
	
end
