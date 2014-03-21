if(!Array.indexOf){
  Array.prototype.indexOf = function(obj){
    for(var i=0; i<this.length; i++){
      if(this[i]==obj){
        return i;
      }
    }
    return -1;
  }
}

function convertAtomDateString(str){
	date = str.slice(5,7);
	month = str.slice(8,11);
	var months = new Array("","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
  month_number = months.indexOf(month);
  month_number += '';
  if(month_number.length==1){ month_number = "0" + month_number }
  return date + "/" + month_number
}