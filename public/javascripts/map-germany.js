function showLander(lander) {
	var title = lander.getAttribute("title")
	var l = document.getElementById("lander")
	l.firstChild.nodeValue = title
}

function showLanderDefaultText(lander) {
	var l = document.getElementById("lander")
	l.firstChild.nodeValue = "Cliquer sur un Land"
}

function prepareMap(){
	if (!document.getElementByTagName) return false;
	if (!document.getElementById) return false;
	if (!document.getElementById("map-germany")) return false;
	var map = document.getElementById("map-germany")
	var areas = map.getElementByTagName("area")
	
	for(var i=0; i < areas.length; i++) {
		areas[i].onmouseover = function(){
			showLander(this);
			return false;
		}
	}
}

addLoadEvent(prepareMap);