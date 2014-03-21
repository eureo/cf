require 'open-uri'
require 'hpricot'
require 'json'

class HomeController < ApplicationController

  caches_page :index
  
  layout "home"

  before_filter :get_nav_categories
  before_filter :get_regions
  
  CampaignMonitor::CAMPAIGN_MONITOR_API_KEY = "7fc49ec9a083d6d7ee891a88f65a38cf"

  def index
    # @article_une = get_article_by_tags(['home_une'])[0]
    #     @articles_deux = get_article_by_tags(['home_deux'])
    #     
    #     if @articles_deux.size > 4
    #       @articles_deux = @articles_deux[0..3]
    #     end
    
    @edito = get_article_by_tags(['edito'])[0]
    
    @agenda_feed = Hpricot get_agenda_feed
    @forum_feed = Hpricot get_forum_feed
    
    @offer_feed = JSON.parse get_offer_feed
    
    @regions_and_number_of_articles = Category.get_regions_and_articles_number
    @page_title << " - Le site des français et francophones en Allemagne"
  end  
  
  def contact
    return unless request.post?
    message = params[:message]
    send_email(message)
    flash[:notice] = "Votre message a été envoyé correctement."
    redirect_to home_url
  end

  def newsletter_signin
    #breakpoint
    return unless request.post?
    
    unless params[:mail].empty? or params[:zonegeo].empty?
    
      signin_to_campaign_monitor(params[:mail], params[:zonegeo])
    
      @message = Hash.new
      @message['email'] = params[:mail]
      @message['zonegeo'] = params[:zonegeo]
      Superman::deliver_inscription_newsletter(@message)
      Superman::deliver_confirmation_inscription_newsletter(@message)
      redirect_to article_url("confirmation-newsletter")
    else
      flash[:warning] = "Vous devez indiquez une zone géographique"
      redirect_to :action => "index"
    end
  end
  
  def newsletter_signout
    return unless request.post?
    
    signout_from_campaign_monitor(params[:email])
    
    @message = Hash.new
    @message['email'] = params[:email]
    Superman::deliver_desinscription_newsletter(@message)
    Superman::deliver_confirmation_desinscription_newsletter(@message)
    redirect_to article_url("confirmation-desinscription-newsletter")
  end
  
  def search
    render :action => "search", :layout => "search"
  end
  
  protected
  
  def get_agenda_feed
    begin
      open(AGENDA_FEED)
    rescue
      ""
    end
  end
  
  def get_forum_feed
    begin
      open(FORUM_FEED)
    rescue
      ""
    end
  end
  
  def get_offer_feed
    begin
      open(OFFER_FEED).read
    rescue
      ""
    end
  end
  
end
