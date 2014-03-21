class RegionController < ApplicationController

  caches_page :show, :article

  layout "region"

  before_filter :get_nav_categories
  before_filter :get_regions
  before_filter :get_current_region, :except => "index"
  before_filter :reaction, :only => "article"
  
  def index
    #default_region = Category.find_by_permalink("regions").children.first
    #redirect_to :action => :show, :id => default_region.permalink
    @articles = Article.ez_find(:all, :limit => 10, :include => :category, :order => "published_at desc") do |article, category|
      article.published == 1
      category.id === @regions.map{|c| c.id }
    end
  end

  def show
    @region = Category.find_by_permalink(params[:id])
    if @current_region == @region
      @articles = {}
      @articles[@region] = Article.ez_find(:all, :include => :category) do |article, category|
        article.published == 1
        category.permalink == @region.permalink
      end
      
      subcategories = @region.children 
      logger.debug("SUBCATEGORIES : #{subcategories.map{|c| c.name }}")
      
      for cat in subcategories
        @articles[cat] = Article.ez_find(:all, :include => :category) do |article, category|
          article.published == 1
          category.permalink == cat.permalink
        end
      end
  
      logger.debug("ARTICLES CAT : #{@articles.keys.map{|c| c.name }}")
  
      all_articles_sorted = @articles.values.flatten.sort_by {|a| a.published_at }.reverse
      @last_article = all_articles_sorted[0]
      if @last_article.nil?
        no_article_in_this_region
      end
      
    else
      articles = Article.ez_find(:all, :include => :category, :order => "published_at desc") do |article, category|
        article.published == 1
        category.permalink == params[:id]
      end
      @first_article = articles[0]
      @remaining_articles = articles[1..articles.size] || ""
    end
    
    @page_title << " - #{@region.name}" unless @region.nil?
    
  end
  
  def article
    @article = Article.ez_find(:first) do |article|
      article.published == 1
      article.permalink == params[:id]
    end
    
    if @article.nil? then
      flash[:warning] = "page not found"
    else
      @page_title << " - #{@article.title}" unless @article.nil?
    end
    
  end
  
  private
  
  def no_article_in_this_region
    @no_article = Article.ez_find(:first) do |article|
      article.published == 1
      article.permalink == "aucun-article-pour-ce-land"
    end
  end
  
  
end
