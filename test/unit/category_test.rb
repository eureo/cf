require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../app/models/article'

class CategoryTest < Test::Unit::TestCase
  fixtures :categories, :articles

	def setup
		@record = Category.find(:first)
	end

	def test_create
  	test_creation_of :model => Category,
											:record => @record,
											:fixture => Category.find(:first),
											:attributes => [:name]
	end

	def test_update
		test_updating_of :record => @record,
											:fixture => "Offres",
											:attribute => :name
	end

	def test_delete_leaf_category
		test_destruction_of :model => Category,
												:record => Category.find_by_permalink('en-france')
	end

	# destroying Infos Pratiques should detroy all 3 subcategories as well
	def test_delete_a_complete_category_branche
		old_count = Category.count
		category = Category.find_by_permalink('infos-pratiques')
	  category.destroy
		assert_equal old_count - 4, Category.count
	end

  def test_delete_articles_on_deleting_category
    category = Category.find(2)
    articles_old_count_cat1 = Article.find_all_by_category_id(2).size
    articles_old_count_cat2 = Article.find_all_by_category_id(3).size
    category.destroy
    assert_not_equal articles_old_count_cat1, 0
    assert_not_equal articles_old_count_cat2, 0
    assert_equal 0, Article.find_all_by_category_id(2).size
    assert_equal 0, Article.find_all_by_category_id(3).size
  end

	def test_permalink
		category = Category.new :name => "Un nom quelconque accentué"
		category.save
		category.reload
		assert_equal category.permalink, "un-nom-quelconque-accentue"
	end
	
	def test_find_by_permalink
		assert_not_nil Category.find_by_permalink("infos-pratiques")
		assert_nil Category.find_by_permalink("une-categorie-bidon")
	end
	
end
