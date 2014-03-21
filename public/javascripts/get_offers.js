// GET LAST JOB OFFERS
$(function() {
  var config = {
    'sector'      : '',
    'location'    : '',
    'limit'       : 6 ,
  }
  var offer_url = 'http://www.connexion-emploi.com/offers/'
  var json_url = 'http://www.connexion-emploi.com/offers/feed2?callback=?';
  
  $.getJSON(json_url, {sector: config.sector, location: config.location, limit: config.limit}, function(data){    
    var element = $("#ce");
    
    $.each(data, function(i, item){
      var li = $("<li></li>");
      var a = $("<a></a>")
      
      a.text(item.offer.title)
        .attr("href", offer_url + item.offer.permalink)
        .attr("target", "_blank");
          
      a.appendTo(li);  
      li.appendTo(element.find("ul"));
    });
    

  });
});