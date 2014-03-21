class ArticlesController < ApplicationController
  
  caches_page :show
  
  layout "category"

  before_filter :get_nav_categories, :except => :test_rss
  before_filter :get_regions, :except => :test_rss
  
  def show
    @article = Article.ez_find(:first) do |article|
      article.published == 1
      article.permalink == params[:id]
    end
    
    if @article.nil? then
      flash[:warning] = "page not found"
    else
      reaction(@article)

      @page_title << " - #{@article.title}" unless @article.nil?
      get_other_articles
    end    
  end
  
  private

  # affiche la reaction a un article seulement si pas un article à la racine (root)
  def reaction(art)
    article_without_reaction = Article.ez_find(:all, :include => :category) do |article, category|
      article.published == 1
      category.permalink == "root"
    end
    article_without_reaction.each{|a| puts a.permalink }
    puts art.permalink
    return if article_without_reaction.detect{|a| a.permalink == art.permalink}
    @reaction = Article.ez_find(:first) do |article|
      article.published == 1
      article.permalink == "reaction"
    end
  end
  
end
