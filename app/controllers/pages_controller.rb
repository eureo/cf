class PagesController < ApplicationController
  
  layout "pages"

  def show
    @article = Article.ez_find(:first) do |article|
      article.published == 1
      article.permalink == params[:id]
    end
      
    @page_title << " - #{@article.title}" unless @article.nil?
  end
  
end
