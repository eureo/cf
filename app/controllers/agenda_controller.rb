class AgendaController < ApplicationController
  
  layout "agenda"

  before_filter :get_nav_categories
  before_filter :get_regions
  
  def index
    @article = Article.find_published_by_permalink("agenda")
    @page_title << " - Agenda"
  end


	def mailer
    return unless request.post?
    message = params[:message]
    send_email(message)
    flash[:notice] = "Votre message a été envoyé correctement."
    redirect_to :action => :index
  end
	
end
