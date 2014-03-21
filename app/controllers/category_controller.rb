class CategoryController < ApplicationController

  caches_page :show

  layout "category"

  before_filter :get_nav_categories
  before_filter :get_regions
  
  def index
    @articles = Article.ez_find(:all, :limit => 10, :include => :category, :order => "published_at desc") do |article, category|
      article.published == 1
      category.id === @categories.map{|c| c.id }
    end
  end

  def show
    @category = Category.find_by_permalink(params[:id])
    articles = Article.ez_find(:all, :include => :category, :order => "published_at desc") do |article, category|
      article.published == 1
      category.permalink == params[:id]
    end
    @page_title << " - #{@category.name}" unless @category.nil?
    @first_article = articles[0]
    @remaining_articles = articles[1..articles.size] || ""
  end
  
  def regions
    redirect_to :controller => "region", :action => "show", :id => params[:region]
  end
  
end
