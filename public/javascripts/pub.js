$(function(){
  
  PATH = "/images/pubs/";
  
  var items = [
    ["pub_epp_230x110.jpg","http://avocat.de"],
    ["pub_villa_230x110.png","http://villafrance.de"],
    ["pub_desray_230x110.png","http://www.connexion-emploi.com/partners/thomas-desray"],
    ["pub_eurojob_230x110.png","http://eurojob-consulting.com/"],
    ["pub_cf_defra_connecti_230x110.png", "http://connecti.de"],
    ["pub_eureo_230x110.jpg", "http://www.eureo.fr"],
    ["willkommen_in_deutschland_230x110.png", "http://www.willkommen-in-deutschland.fr/"]
  ];
  
  var index = Math.floor(Math.random()*items.length);
  var container = $("#pub_sidebar");
  
  var a = $("<a target='_blank'></a>");
  a.attr('href', items[index][1]);

  var image = $("<img/>");
  image.attr('src', PATH + items[index][0]);  
  
  image.appendTo(a);
  a.appendTo(container);
});