require 'cgi'

module HomeHelper
  include ApplicationHelper
  
  def display_edito(edito)
    html = "<div id='edito' class='box'><h2><a href='#'>Edito</a></h2><div class='box-content'>"
    if edito
      html << read_more(edito.excerpt_html || "", page_path(edito), "lire la suite").to_s
    end
    html << "</div>"
    html << "<div class='box-footer'>&nbsp;</div>"
    html << "</div>"
    html
  end
  
  def pub
    html = "<div id='pub-home'>&nbsp;</div>"
  end
  
  def vivre_en_allemagne(categories)
    html = "<div class='box' id='vivre-en-allemagne'><h2>#{link_to 'Vivre en Allemagne', url_for(:controller => 'category')}</h2><div class='box-content'>"
    html << "<h3>Retrouvez nos conseils pratiques</h3>"
    html << "<ul>"
    for category in categories
      html << "<li>"
      if category.published_articles && category.published_articles.size > 0
        html << "#{link_to category.name + '&nbsp;(' + category.published_articles.size.to_s + ')', category_path(category)}"
      else
        html << "#{link_to category.name, category_path(category)}"
      end
      
      html << "</li>"
    end
    html << "</ul>"
    html << "</div>"
    html << "<div class='box-footer'>&nbsp;</div>"
    html << "</div>"
  end
  
  def agenda(agenda_feed)
    html = "<div class='box' id='agenda'><h2><a href='http://forum.connexion-francaise.com/viewforum.php?f=62'>Agenda</a></h2><div class='box-content'>"
    html << "<dl>"
    #i = 0
    #for event in agenda_feed.search("entry")    
      #date_array = (event/'gd:when').first.attributes['starttime'].scan(/(\d{4})-(\d{2})-(\d{2})/)
      #date = "#{date_array[0][2]}/#{date_array[0][1]}"
      #title = (event/'title').first.inner_html
      #escaped_content = (event/'content').first.inner_html
      #content = CGI.unescapeHTML(escaped_content)
      #html << "<dt>#{date}</dt>"
      #html << "<dd class='event'>"
      #html << "<a class='event-trigger' href='#'>#{title}</a>"
      #html << "<div class='event-details'><div id='event-#{i}' style='padding:10px;'><h2 style='margin-bottom:15px;'>#{title}</h2><p style='margin-bottom:15px;'>Date : #{date}</p><p style='margin-bottom:15px;'>#{content}</p></div></div>"
      #html << "</dd>"
      #i = i + 1
    #end
    html << "</dl>"
    html << "</div>"
    html << "<div class='box-footer'><a href='http://forum.connexion-francaise.com/viewforum.php?f=62'>Voir tous les événements</a></div>"
    html << "</div>"
  end
  
  def forum(forum_feed)
    html = "<div class='box' id='forum'><h2><a target='_blank' href='#{FORUM_URL}'>Forum</a></h2><div class='box-content'>"
    html << "<p class='cat'><strong>catégories</strong> : <a target='_blank' href='#{FORUM_URL}/viewforum.php?f=8'>entraide</a> - <a target='_blank' href='#{FORUM_URL}/viewforum.php?f=57'>tribunes locales</a></p>"
    html << "<dl>"
    #for topic in forum_feed.search("entry")
    #  title = (topic/"title").first.inner_text
    #  link = (topic/"link").first.attributes["href"]
    #  html << "<li><a  target='_blank' href='#{link}'>#{title}</a></li>"
    #end
    html << "</dl>"
    html << "</div>"
    html << "<div class='box-footer'><a target='_blank' href='#{FORUM_URL}'>Voir toutes les discussions</a></div>"
    html << "</div>"
  end
  
  def petites_annonces
    html = "<div class='box' id='annonces'><h2><a target='_blank' href='#{ANNONCE_URL}'>Petites annonces</a></h2><div class='box-content'>"
    html << "<dl>"
    html << "</dl>"
    html << "</div>"
    html << "<div class='box-footer'><a target='_blank' href='#{ANNONCE_URL}'>Voir toutes les petites annonces</a></div>"
    html << "</div>"
  end
  
  def actualite_lpj
    html = "<div class='box' id='lpj'><h2><a href='/news' class='title'>Actualité</a><a href='http://lepetitjournal.com/' class='logo'>Le petit journal</a></h2><div class='box-content'>"
    html << "<dl></dl>"
    html << "</div>"
    html << "<div class='box-footer'><a href='/news'>Voir toutes les actualités</a></div>"
    html << "</div>"
  end
  
  def offres_emploi(offer_feed)
    html = "<div class='box' id='ce'><h2><a target='_blank' href='http://www.connexion-emploi.com/fr' class='title'>Offres d'emploi</a><a href='http://www.connexion-emploi.com/' class='logo'>Connexion Emploi</a></h2><div class='box-content'>"
    html << "<ul>"
    #for offer in offer_feed
    #  title = offer["offer"]["title"] 
    #  link = offer["offer"]["permalink"] 
    #  html << "<li><a target='_blank' href='#{link}'>#{title}</a></li>"
    #end
    html << "</ul>"
    html << "</div>"
    html << "<div class='box-footer'><a target='_blank' href='http://www.connexion-emploi.com'>Toutes les offres franco-allemandes</a></div>"
    html << "</div>"
  end
  
  def pres_de_chez_vous(regions)
    html = "<div class='box' id='regions'><h2><a href='/region'>Près de chez vous</a></h2><div class='box-content'>"
    html << "<ul>"
    for region in regions
      html << "<li>#{link_to region[0].name + '&nbsp;(' + region[1].to_s + ')' , region_path(region[0])}</li>"
    end
    html << "</ul>"
    html << "</div>"
    html << "<div class='box-footer'>&nbsp;</div>"
    html << "</div>"
  end
  
end
  
