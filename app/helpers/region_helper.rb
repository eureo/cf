#require 'open-uri'
require 'rss'

module RegionHelper
  
  def read_regional_offer_rss(feed_url, region_name)
    output = "<h3>Les dernieres offres d'emplois dans la région : <span class='region'>#{region_name}</span></h3>"
    #open("http://"+ feed_url) do |http|
    #  response = http.read
    response = `curl #{feed_url}`
    result = RSS::Parser.parse(response, false)
    output << "<ul>"
    result.items.each_with_index do |item, i|
      output << "<li>"
      output << "<a href=\"#{item.link}\" target=\"_blank\">#{item.title}</a>"
      output << "</li>"
    end  
    output << "<ul>"
    return output
  end
  
  
end
