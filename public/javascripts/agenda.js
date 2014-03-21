// AGENDA
$(function() {
  var feed = new google.feeds.Feed("http://forum.connexion-francaise.com/syndication.php?type=atom&chars=1&t=2&fid=62");
  
  feed.setNumEntries(9);
  feed.load(function(data){
    var element = $("#agenda");
    var items = data.feed.entries;
      
    $.each(items, function(i, item){
      var dt = $("<dt></dt>");
      var dd = $("<dd></dd>");
      var a = $("<a></a>");
      var date = $("<span class='date'></span>");
      
      date.text(convertAtomDateString(item.publishedDate));          
                  
      a.text(item.title)
        .attr("href", item.link)

      date.appendTo(dt);
      a.appendTo(dd);  
      dt.appendTo(element.find("dl"));
      dd.appendTo(element.find("dl"));
      
      
    });
    
  });    
});


//$(function() {
  //$("a.event-trigger").each(function(index){    
    //$(this).colorbox({width:'50%',inline:true,href:"#event-" + index});
  //});
  
  //$(".event-details a").click(function(e){
    //var href = $(this).attr('href'); 
    //e.preventDefault();
    //window.open(this.href);
    //return false;
  //});
//});
