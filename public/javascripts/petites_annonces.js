// PETITE ANNONCES  
$(function() {
  var feed = new google.feeds.Feed("http://forum.connexion-francaise.com/syndication.php?type=atom&chars=1&t=2&fid=4,6,50");
  feed.setNumEntries(9);
  feed.load(function(data){
    var element = $("#annonces");
    var items = data.feed.entries;
    
    $.each(items, function(i, item){
      var dt = $("<dt></dt>");
      var dd = $("<dd></dd>");
      var a = $("<a></a>")
      var date = $("<span class='date'></span>")
      
      date.text(convertAtomDateString(item.publishedDate));
              
      a.text(item.title)
        .attr("href", item.link)
        .attr("target", "_blank");

      date.appendTo(dt);
      a.appendTo(dd);  
      dt.appendTo(element.find("dl"));
      dd.appendTo(element.find("dl"));
    });
    
  });    
});