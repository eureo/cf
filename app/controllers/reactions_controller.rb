class ReactionsController < ApplicationController
  
  layout "category"
  
  before_filter :get_nav_categories, :except => :test_rss
  before_filter :get_regions, :except => :test_rss
  
  def new
    @reaction = Reaction.new
  end
  
  def create
    @reaction = Reaction.new(params[:reaction])
    if @reaction.save
      if params[:reaction][:answer] == "14"
        message = {
          'reponse' => @reaction.answer,
          'article' => @reaction.article,
          'subject' => @reaction.subject,
          'content' => @reaction.content,
          'email' => @reaction.email,
          'recipient' => 'contact'
        }
        send_email(message)
      end
      flash[:notice] = "Votre message a été envoyé correctement."
      redirect_to home_url
    else
      render :action => :new
    end
  end
  
end
