require 'localization_settings'
require 'switch_language'
require 'lib_cms'
require 'additional_tag_functions'
require 'caboose_memcached'

class ApplicationController < ActionController::Base
  include LocalizationSettings
  #include ExceptionNotifiable
  include CabooseMemcached
  include Franck::SwitchLanguage
  include Franck::CMS
  include Franck::AdditionalTagFunctions
  include ApplicationHelper

  before_filter :locale, :except => "set_lang"
  before_filter :login_user_from_cookie
 # before_filter :login_candidate_from_cookie
  before_filter :default_page_title

  def send_email(message)
    message_body = []
    message.each do |key, value|
      message_body << key + ' : '
      message_body << value
      message_body << "\n"
    end
    @message = Hash.new
    @message['body'] = message_body
    @message['recipient'] = message['recipient'] || 'contact'
		if message['subject'].nil?
    	@message['subject'] = "[CF] Envoyé via un formulaire - #{timestamp}"
		else
			@message['subject'] = "[CF] via formulaire : #{message['subject']} - #{timestamp}"
		end
    Superman::deliver_message(@message)
  end
  
  def timestamp
    Time.now.utc.iso8601.gsub(/\W/, '')
  end

  def get_nav_categories
    vivre_en_allemagne = Category.find_by_permalink("vivre-en-allemagne")
    @categories = vivre_en_allemagne.children
  end

  def get_regions
    regions = Category.find_by_permalink("regions")
    @regions = regions.children.sort_by{|r| r.name }
  end
  
  def get_current_region
    return unless params[:controller] == "region"
    cat = Category.find_by_permalink(params[:id])
    if cat.nil?
      art = Article.find_by_permalink(params[:id])
      cat = art.category
    end
    categories = []
    categories << cat
    categories << cat.ancestors.reject!{|c| c.permalink == "root" }
    categories.flatten!
    @current_region = categories.detect{|c| c.parent.permalink == "regions" }
  end  
  
  def reaction
    @reaction = Article.ez_find(:first) do |article|
      article.published == 1
      article.permalink == "reaction"
    end
  end

  def get_other_articles
    return if @article.nil?
    cat = @article.category    
    @other_articles = Article.ez_find(:all, :include => :category, :order => "published_at desc") do |article, category|
      article.published == 1
      category.permalink == cat.permalink
    end
    @other_articles = get_random_articles(@other_articles)
    @other_articles ||= "" 
    @other_articles.reject! {|a| a == @article }
    @other_articles.reject! {|a| a.category.permalink == "root" }
  end

  def default_page_title
    @page_title = "Connexion Française"
  end

  def login_user_from_cookie
    return unless session[:user].nil? && cookies[:auth_token]
    self.current_user = User.find_by_remember_token(cookies[:auth_token])
  end
  
  # saving the last request uri
  after_filter :save_last_request_uri
  def save_last_request_uri
    if request.get? and response.redirected_to.nil? and request.env["PATH_INFO"] != "/cv/accord"
      session[:last_request_uri] = session[:this_request_uri]
      session[:this_request_uri] = request.request_uri
      session[:last_unique_request_uri] = session[:last_request_uri] if session[:this_request_uri] != session[:last_request_uri]
    end
  end

  def show_tags_list
    @tags_list = Tagging.find(:all).collect { |tagging| tagging.tag }.uniq
    render false
  end
  
  helper_method :last_request_uri
  def last_request_uri
    if session[:this_request_uri] == request.request_uri
      if session[:this_request_uri] == session[:last_request_uri]
        session[:last_unique_request_uri]
      else
        session[:last_request_uri]
      end
    else
      session[:this_request_uri]
    end
  end


  helper_method :toggable_location
  def toggable_location(root, lvl = 1)
    html = []
    unless root.children.size == 0
      html << "<ul id=\"location_#{root.id}\">"
      root.children.each do |child|
        html << "<li>#{child.name}</li>"
      end
      html << "</ul>"
    end

    return html if lvl == 1

    root.children.each do |lvl1|
      unless lvl1.children.size == 0
        html << "<ul id=\"location_#{lvl1.id}\" style=\"display:none;\">"
        lvl1.children.each do |child|
          html << "<li>#{child.name}</li>"
        end
        html << "</ul>"
      end
    end

    return html if lvl == 2

    root.children.each do |lvl1|
      lvl1.children.each do |lvl2|
        unless lvl2.children.size == 0
          html << "<ul id=\"location_#{lvl2.id}\" style=\"display:none;\">"
          lvl2.children.each do |child|
            html << "<li>#{child.name}</li>"
          end
          html << "</ul>"
        end
      end
    end
    return html
  end

  def paginate_collection(collection, options={})
    default_options = { :per_page => 10, :page => 1 }
    options = default_options.merge(options)
    pages = Paginator.new(self, collection.size, options[:per_page], options[:page])
    first = pages.current.offset
    last = [first + options[:per_page], collection.size].min
    slice = collection[first...last]
    return [pages, slice]
  end
  
  # paginator for ferret search  
  def pages_for(size, options = {})
    default_options = {:per_page => 3}
    options = default_options.merge options
    pages = Paginator.new self, size, options[:per_page], (params[:page]||1)
    pages
  end
  

  protected

  # need by hook login_user_from_cookie (not very DRY)
  helper_method :current_user
  def current_user
    @current_user ||= session[:user] ? User.find_by_id(session[:user]) : nil
  end

  def current_user=(new_user)
    session[:user] = new_user.nil? ? nil : new_user.id
    @current_user = new_user
  end
  
  def get_random_articles(articles, number = 5)
    
    return articles if articles.size <= number
    # get n number between 0 and articles.size - 1
    indexes = []
    
    while(indexes.size < number)
      n = ((articles.size - 1) * rand).floor
      indexes << n unless indexes.include?(n)
    end
    indexes.sort!
    random_articles = []
    for index in indexes
      random_articles << articles[index]
    end
    return random_articles
  end
  
  def signout_from_campaign_monitor(email)		
		sub = CampaignMonitor::Subscriber.new(email)
		sub.unsubscribe("ba0c8e9e1db27b73af947308b445dab0")
	end
  
  def signin_to_campaign_monitor(email, zonegeo)
    list = CampaignMonitor::List.new("ba0c8e9e1db27b73af947308b445dab0")
    custom_field = []
    custom_field << { "Lander" => zonegeo }
    list.add_and_resubscribe_with_custom_fields(email, "cf", custom_field)
  end
  
  def signin_to_mailchimp(email, zonegeo)
    logger.debug("IN SIGNIN TO MAILCHIMP : #{email}, #{zonegeo}")
    h = set_mailchimp
    groupings = [
      { "name" => "zonegeo", "groups" => zonegeo }
    ]
    merges = {
      "GROUPINGS" => groupings
    }
    h.subscribe(MAILCHIMP_LIST_ID, email, merges)
  end
  
  def signout_from_mailchimp(email)
    logger.debug("IN SIGNOUT FROM MAILCHIMP")
    h = set_mailchimp
    h.unsubscribe(MAILCHIMP_LIST_ID, email)
  end
  
  def set_mailchimp
    h = Hominid::Base.new({:api_key => MAILCHIMP_API_KEY })
    return h
  end
  

end
