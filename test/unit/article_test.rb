require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :articles

	def setup
		@record = Article.find(:first)
	end

	def test_create
  	test_creation_of :model => Article,
											:record => @record,
											:fixture => Article.find(:first),
											:attributes => [:title]
	end

	def test_update
		test_updating_of :record => @record,
											:fixture => "Un titre",
											:attribute => :title
	end

	def test_delete
		test_destruction_of :model => Article,
												:record => @record
	end

	def test_permalink
		article = Article.new :title => "Un titre quelconque accentué"
		article.save
		article.reload
		assert_equal article.permalink, "un-titre-quelconque-accentue"
	end
	
	def test_find_by_permalink
		assert_not_nil Article.find_by_permalink(@record.permalink)
		assert_nil Article.find_by_permalink("un-article-bidon")
	end
	
	def test_transform_body
		@record.attributes = { :title => "un nouveau titre", :excerpt => "h1. test\n\n", :body => "*essai*"}
		@record.save
		@record.reload
		assert_equal @record.excerpt_html, "<h1>test</h1>"
		assert_equal @record.body_html, "<p><strong>essai</strong></p>"
	end
	
end
