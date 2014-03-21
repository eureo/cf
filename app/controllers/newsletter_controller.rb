#require 'campaign_monitor'
require "email_validator"

class NewsletterController < ApplicationController
  
  layout "pages"
	
	skip_after_filter :add_google_analytics_code, :only => ["show"]

	caches_page :show
	
	CampaignMonitor::CAMPAIGN_MONITOR_API_KEY = "7fc49ec9a083d6d7ee891a88f65a38cf"

	def show
		@html_newsletter = HtmlNewsletter.find_by_permalink(params[:title])
		render :action => :show, :layout => "html_newsletter"
	end
	
	def new
  end
  
  def create
    return unless request.post?
    
    if params[:mail] and EmailValidator.validate_email(params[:mail])
      if params[:zonegeo]
        signin_to_campaign_monitor(params[:mail], params[:zonegeo])
        @message = Hash.new
        @message['email'] = params[:mail]
        @message['zonegeo'] = params[:zonegeo]
        signin_to_mailchimp(params[:mail], params[:zonegeo])
        Superman::deliver_inscription_newsletter(@message)
        Superman::deliver_confirmation_inscription_newsletter(@message)
        redirect_to :action => "thanks"
      else
        flash[:error] = "Vous devez indiquez une zone géographique"
        redirect_to :action => "new"
      end
    else
      flash[:error] = "Email manquant ou incorrect"
      redirect_to :action => "new"
    end
  end
  
  def thanks
  end
  
  def signout
  end  
  
  def signingout
    if params[:mail] && EmailValidator.validate_email(params[:mail])
      signout_from_mailchimp(params[:mail])
      flash[:notice] = "Désinscription prise en compte. Vous pouvez vous réabonner en utilisant le formulaire ci-dessous."
      redirect_to :action => "new"
    else
      flash[:error] = "Email manquant ou incorrect"
      redirect_to :action => "signout"
    end
  end  
  
  def webhook
    if params[:secretkey].nil? or params[:secretkey] != "mc-secret-cf99"
      flash[:notice] = "Acces restreint"
      redirect_to root_url
    else
      @text = "OK"
      if params[:type] == "unsubscribe"
        signout_from_mailchimp(params[:data][:email])
      end
      render :layout => false
    end
  end

end
