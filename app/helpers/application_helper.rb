require 'open-uri'
require 'rss'

module ApplicationHelper
  include LocalizationSettings
  
  FORUM_URL = "http://forum.connexion-francaise.com"
  ANNONCE_URL = "#{FORUM_URL}/viewforum.php?f=56"
  AGENDA_FEED = "http://www.google.com/calendar/feeds/agenda%40connexion-francaise.com/public/full?orderby=starttime&futureevents=true&sortorder=a&max-results=5"
  AGENDA_LINK = "http://www.google.com/calendar/hosted/connexion-francaise.com/embed?src=agenda%40connexion-francaise.com&ctz=Europe/Berlin"
  FORUM_FEED = "#{FORUM_URL}/feed.php?mode=news"
  OFFER_FEED = "http://www.connexion-emploi.com/offers/feed2?limit=9"

    
  def markdown(text)
    BlueCloth.new(text.gsub(%r{</?notextile>}, '')).to_html
  end

  def filtertext(text)
    RedCloth.new(text.gsub(%r{</?notextile>}, ''), [:hard_breaks]).to_html
  end

  def read_more(text, link, link_text = 'read more', before_link = "&nbsp;&nbsp;", after_link = "")
    return if text.nil? or text.empty?
    markup = text.chop.split("</").last
    html = []
    html << text[0..text.size-(markup.size+4)]
    html << before_link
    html << link_to(l(link_text), link)
    html << after_link
    html << "</#{markup}>"
  end
  
  def newsletter_url(newsletter)
		url_for :only_path => true, :controller => '/newsletter', :action => :show, :title => newsletter.permalink
	end
	
	#def newsletter_url(newsletter)
	#	url_for :only_path => true, :controller => '/newsletter', :action => :show, :year => newsletter.published_at.year, :month => sprintf("%.2d", newsletter.published_at.month), :day => sprintf("%.2d", newsletter.published_at.day), :title => newsletter.permalink
	#end
	  
	def newsletter_path(newsletter)
		url_for :only_path => false, :controller => '/newsletter', :action => :show, :title => newsletter.permalink
	end

  # load indicator
  # options to insert in the link_to_remote:
  # :loading => "Element.show('load-indicator');",
  # :complete => "Element.hide('load-indicator');" 
  def load_indicator(color = 'black')
    html = ""
    html << "<div id=\"load-indicator\" class=\"#{color}-loader\" style=\"display:none\" >"
    html << "</div>"
  end

  def arrow_indicator 
    html = ""
    html << "<img src=\"/images/indicator_arrows.gif\" id=\"arrow-indicator\" alt=\"arrow indicator\" style=\"display:none;\" />"
  end

  def my_pagination_links(paginator, collection, options = {} )
    unless paginator.page_count < 2
      collection_name = options[:collection_name] || l('Results')
      per_page = options[:per_page] || 10
      params = options[:params] || ""
      current_page = paginator.current_page
      html = ""
    
      html << "<div id='pagination'>"
      html << "<div id='page'>"

      html << l("Pages") + " "
    
      for i in 1..paginator.last.number
        html << (link_to_and_highlight_if_current i, paginator, { :params => params.merge(:page => i)})
        html << "&nbsp;"
      end

      html << "</div>"
      html << "<div id='previous-and-next'>"
      # Previous
      if paginator.current.previous
        html << (link_to "<<&nbsp;" + l('previous'), { :params => params.merge( 
        :page => paginator.current.previous.number )}) 
        html << " "
      end

      # Next
      if paginator.current.next
        html << " "
        html << (link_to l("next") + "&nbsp;>>", { :params => params.merge(
        :page => paginator.current.next.number )}) 
      end
  
      html << "</div>"
      html << "</div>"
      html << "<div class='clear'>&nbsp;</div>"
      return html
    end
  end
  
  def link_to_article_if_permit(before = "", after = "")
    html = []
    if params[:controller] == 'articles' and params[:action] == 'show'
      if permit? 'cms'
        html << before
        html << ' | ' 
        html << "#{link_to l('edit'), { :controller => 'admin/cms/pages', :action => 'show', :id => @article.permalink }, { :class => 'private'}}"
        html << after
      end
    end
  end 
  
  def link_to_and_highlight_if_current(name, paginator, options ={}, html_options={})
    if name.to_s == params[:page] or (params[:page].nil? and name == 1)
      link_to name.to_s, options, html_options.merge( :class => "strong" )
    else
      link_to name.to_s, options, html_options
    end
  end
  
  def breadcrumbs_category(category)
    return if category.nil?
    cat = []
    cat = category.ancestors.collect {|c| c }
    cat.reject! {|c| c.permalink == "root" or c.permalink == "vivre-en-allemagne" or c.permalink == "regions"}
    html = ""
    html << "<div id='breadcrumbs'>"
    html << "#{link_to 'Connexion Française', home_url }"
    html << "&nbsp;>&nbsp;"
    
    html << "#{link_to 'Vivre en Allemagne', url_for(:controller => 'category') }"
    html << "&nbsp;>&nbsp;"
    
    if cat.size > 0
    html << cat.collect {|c| link_to l(c.name), category_path(c) }.join('&nbsp;>&nbsp;')
    html << "&nbsp;>&nbsp;"
    end
    html << category.name.capitalize
    html << "</div>"
  end

  def breadcrumbs_region(category)
    return if category.nil?
    cat = []
    cat = category.ancestors.collect {|c| c }
    cat.reject! {|c| c.permalink == "root" or c.permalink == "vivre-en-allemagne" or c.permalink == "regions"}
    html = ""
    html << "<div id='breadcrumbs'>"
    html << "#{link_to 'Connexion Française', home_url }"
    html << "&nbsp;>&nbsp;"
    
    html << "#{link_to 'Près de chez vous', url_for(:controller => 'region', :action => "index") }"
    html << "&nbsp;>&nbsp;"
    
    if cat.size > 0
    html << cat.collect {|c| link_to l(c.name), region_path(c) }.join('&nbsp;>&nbsp;')
    html << "&nbsp;>&nbsp;"
    end
    html << category.name.capitalize
    html << "</div>"
  end


  def breadcrumbs_article(article)
    return if article.nil?
    category = []
    category = article.category.ancestors.collect {|c| c }
    category << article.category
    category.reject! {|c| c.permalink == "root" or c.permalink == "vivre-en-allemagne" or c.permalink == "regions"}
    html = ""
    html << "<div id='breadcrumbs'>"
    html << "#{link_to 'Connexion Française', home_url }"
    html << "&nbsp;>&nbsp;"
    
    html << "#{link_to 'Vivre en Allemagne', url_for(:controller => 'category') }"
    html << "&nbsp;>&nbsp;"
    
    if category.size > 0
      html << category.collect {|c| link_to l(c.name), category_path(c) }.join('&nbsp;>&nbsp;')
      html << "&nbsp;>&nbsp;"
    end
    html << article.title.capitalize
    html << "</div>"
  end
  
  def breadcrumbs_regional_article(article)
    return if article.nil?
    category = []
    category = article.category.ancestors.collect {|c| c }
    category << article.category
    category.reject! {|c| c.permalink == "root" or c.permalink == "vivre-en-allemagne" or c.permalink == "regions"}
    html = ""
    html << "<div id='breadcrumbs'>"
    html << "#{link_to 'Connexion Française', home_url }"
    html << "&nbsp;>&nbsp;"
    
    html << "#{link_to 'Près de chez vous', url_for(:controller => 'region', :action => "index") }"
    html << "&nbsp;>&nbsp;"
    
    if category.size > 0
      html << category.collect {|c| link_to l(c.name), region_path(c) }.join('&nbsp;>&nbsp;')
      html << "&nbsp;>&nbsp;"
    end
    html << article.title.capitalize
    html << "</div>"
  end

  # return true if category needs to be highlighted
  def highlight_category(category)
    if params[:controller] == "articles" and params[:action] == "show"
      article = Article.find_by_permalink(params[:id])
      return get_categories(article.category).select {|c| c == category.permalink }.size > 0
    end
    if params[:controller] == "category" and params[:action] == "show"
      cat = Category.find_by_permalink(params[:id])
      return get_categories(cat).select {|c| c == category.permalink }.size > 0
    end    
  end
  
  def highlight_region(region)
    if params[:controller] == "region" and params[:action] == "article"
      article = Article.find_by_permalink(params[:id])
      return get_categories(article.category).select {|c| c == region.permalink }.size > 0
    end
    if params[:controller] == "region" and params[:action] == "show"
      cat = Category.find_by_permalink(params[:id])
      return get_categories(cat).select {|c| c == region.permalink }.size > 0
    end
  end 
  
  def highlight_regional_subcategory(category)
    if params[:controller] == "region" and params[:action] == "article"
      article = Article.find_by_permalink(params[:id])
      return get_categories(article.category).select {|c| c == category.permalink }.size > 0
    end
    if params[:controller] == "region" and params[:action] == "show"
      cat = Category.find_by_permalink(params[:id])
      return get_categories(cat).select {|c| c == category.permalink }.size > 0
    end
  end

  def info_article(article)
    html = []
    unless article.category.permalink == "root"
    html << "<p class='info_article'>"
    html << "Le #{article.published_at.to_formatted_s(:eu_format)}" 
    unless article.author.size == 0
      html << "&nbsp;|&nbsp;  par <span class='author'>#{article.author}</span>,"
    end
    cat = article.category
    if cat.belongs_to_region?
      html << "&nbsp;&nbsp;dans &laquo; #{link_to cat.name, region_path(cat) } &raquo;"
    else
      html << "&nbsp;&nbsp;dans &laquo; #{link_to cat.name, category_path(cat) } &raquo;"
    end
    html << "</p>"
    end
  end
  
  def info_article_deux(article)
    html = []
    unless article.category.permalink == "root"
    html << "<p class='info_article'>"
    unless article.author.size == 0
      html << "par <span class='author'>#{article.author}</span>,"
    end
    cat = article.category
    if cat.belongs_to_region?
      html << "&nbsp;&nbsp;dans &laquo; #{link_to cat.name, region_path(cat) } &raquo;"
    else
      html << "&nbsp;&nbsp;dans &laquo; #{link_to cat.name, category_path(cat) } &raquo;"
    end
    html << "</p>"
    end
  end

  def read_offer_rss(feed_url, offer_number=5)
    output = "<h3>Les dernieres offres d'emplois en <span class='region'>Allemagne</span></h3>"
    open("http://"+ feed_url) do |http|
      response = http.read
      result = RSS::Parser.parse(response, false)
      output << "<ul>"
			items = result.items[0..offer_number-1]
      items.each_with_index do |item, i|
        output << "<li>"
        output << "<a href=\"#{item.link}\" target=\"_blank\">#{item.title}</a>"
        output << "</li>"
      end  
      output << "<ul>"
    end
    return output
  end
  
  def preview_newsletter_url(newsletter)
		url_for :only_path => true, :controller => '/admin/newsletter/html_newsletter', :action => :preview, :id => newsletter
	end

  private
  
  def get_categories(category)
    categories = []
    categories << category.permalink
    categories << category.ancestors.collect {|c| c.permalink }
    return categories.flatten!
  end
  
end
