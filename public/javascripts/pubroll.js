function pubroll() {
	var b1dis = "<a href=\"";
	var bdis = "\"><img src=\"";
	var edis = " width=\"468\" height=\"60\" alt=\"some text\" target=\"_blank\" border=\"0\"></a>";
	/* var edis = " width=\"180\" height=\"180\" alt=\"some text\" target=\"_blank\" border=\"0\"></a>"; */
	var rnumb = "";
	var img = "";
	
	rnumb += Math.floor(Math.random()*7);
	img = rnumb;
	
	/* rexctangle ads */
	if (img == "0") {
		document.write(b1dis+ "http://www.connexion-emploi.com" +bdis+ "/images/pub/long/ce_banniere-468x60.gif\"" +edis);
	}
	
	if (img == "1") {
		document.write(b1dis+ "http://www.eurojob-consulting.com" +bdis+ "/images/pub/long/eurojob-468x60.gif\"" +edis);
	}
	
	if (img == "2") {
		document.write(b1dis+ "mailto:thdesray@yahoo.com?cc=&bcc=&subject=via CF&body=" +bdis+ "/images/pub/long/deray-468x60.gif\"" +edis);
	}
	
	if (img == "3") {
		var uri = 'http://impde.tradedoubler.com/imp?type(js)g(16736504)a(1399400)' + new  String(Math.random()).substring (2, 11);
		document.write('<sc'+'ript type="text/javascript" src="'+uri+'" charset="ISO-8859-1"></sc'+'ript>');
	}

	if (img == "4") {
		document.write(b1dis+ "http://www.a-blok.com/" +bdis+ "/images/pub/long/a-block-468x60.gif\"" +edis);
	}

	if (img == "5") {
		document.write(b1dis+ "http://www.avocat.de/" +bdis+ "/images/pub/long/egk-468x60.gif\"" +edis);
	}
	
	if (img == "6") {
		document.write(b1dis+ "http://www.cineclic.de" +bdis+ "/images/pub/long/cineclic-468x60.gif\"" +edis);
	}
	
	
	/* square ads : Math.random()*9
	if (img == "0") {
		document.write(b1dis+ "http://www.connexion-emploi.com" +bdis+ "/images/pub/ce.gif\"" +edis);
	}
	
	if (img == "1") {
		document.write(b1dis+ "http://www.eurojob-consulting.com" +bdis+ "/images/pub/ej.gif\"" +edis);
	}
	
	if (img == "2") {
		document.write(b1dis+ "http://www.allemagne-au-max.com/" +bdis+ "/images/pub/aom.gif\"" +edis);
	}
	
	if (img == "3") {
		document.write(b1dis+ "http://www.interculturel.com/" +bdis+ "/images/pub/anim.gif\"" +edis);
	}

	if (img == "4") {
		document.write(b1dis+ "http://www.rencontres.de/" +bdis+ "/images/pub/rencontres.jpg\"" +edis);
	}

	if (img == "5") {
		document.write(b1dis+ "http://www.avocat.de/" +bdis+ "/images/pub/kuehl.gif\"" +edis);
	}

	if (img == "6") {
		document.write(b1dis+ "http://www.relocation-muc.com/" +bdis+ "/images/pub/banner.jpg\"" +edis);
	}

	if (img == "7") {
		document.write(b1dis+ "http://www.thesoundsession.com/" +bdis+ "/images/pub/TheSoundSession.gif\"" +edis);
	}

	if (img == "8") {
		document.write(b1dis+ "mailto:thdesray@yahoo.com?cc=&bcc=&subject=via CF&body=" +bdis+ "/images/pub/desray.gif\"" +edis);
	}
	*/
	
	
}
