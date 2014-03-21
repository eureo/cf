// LPJ  
$(function() {
  //var feed = new google.feeds.Feed("http://www.lepetitjournal.com/index.php?option=com_ninjarsssyndicator&feed_id=8&format=raw");
  var feed = new google.feeds.Feed("http://pipes.yahoo.com/pipes/pipe.run?_id=c47536575893715b2c18b6a7849d5679&_render=rss");
  
  feed.setNumEntries(9);
  feed.load(function(data){
    var element = $("#lpj");
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