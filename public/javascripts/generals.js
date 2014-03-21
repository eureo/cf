function addLoadEvent(func) {
	var oldonload = window.onload;
	if (typeof window.onload != 'function') {
		window.onload = func;
	} else {
		window.onload = function() {
			oldonload();
			func();
		}
	}
}

function focusLabels() {
	if (!document.getElementsByTagName) return false;
	var labels = document.getElementsByTagName("label");
	for (var i=0; i < labels.length; i++ ) {
		if (!labels[i].getAttribute("for")) continue;
		labels[i].onclick = function() {
			var id = this.getAttribute("for")
			if (!document.getElementByTagId(id)) return false;
			var element = document.getElementByTagId(id)
			element.focus();
		}
	}
}
addLoadEvent(focusLabels);

function resetFields(whichform) {
	for (var i=0; i<whichform.elements.length; i++) {
		var element = whichform.elements[i];
		if (element.type == "submit") continue;
		if (!element.value) continue;
		element.onfocus = function () {
			if (this.value == this.defaultValue ) {
				this.value = "";
			}
		}
		element.onblur = function () {
			if (this.value == "") {
				this.value = this.defaultValue;
			}
		}
	}
}

function isEmail(field) {
	if (field.value.indexOf("@") == -1 || field.value.indexOf(".") == -1) {
		return false;
	} else {
		return true;
	}
}

function validateForms(whichform) {
	for (var i=0; i<whichform.elements.length; i++) {
		var element = whichform.elements[i];
		if (element.className.indexOf("required") != -1) {
			if (!isFilled(element)) {
				alert("Merci de remplir le champ "+element.name+".");
				return false;
			}
		}
		if (element.className.indexOf("email") != -1) {
			if (!isEmail(element)) {
				alert("Merci de donner une adresse email correcte.");
				return false;
			}
		}
	}
	return true;
}

function prepareForms() {
	for (var i=0; i<document.forms.length; i++) {
		var thisform = document.forms[i];
		resetFields(thisform);
		thisform.onsubmit = function() {
			return validateForms(this);
		}
	}
}
addLoadEvent(prepareForms);

function addClass(element, value) {
	if (!element.className) {
		element.className = value;
	} else {
		newClassName = element.className;
		newClassName += " ";
		newClassName += value;
		element.className = newClassName;
	}
}

function stripTables() {
	if(!document.getElementsByTagName) return false;
	var tables = document.getElementsByTagName("table");
	for (var i=0; i<tables.length; i++) {
		var odd = false;
		var rows = tables[i].getElementsByTagName("tr");
		for (var j=0; j<rows.length; j++) {
			if (odd == true) {
				addClass(rows[j],"odd");
				odd = false;
			} else {
				odd = true;
			}
		}
	}
}
addLoadEvent(stripTables);

function prepareTable() {
	if(!document.getElementsByTagName) return false;
	var tables = document.getElementsByTagName("table");
	for (var i=0; i<tables.length; i++) {
		tables[i].setAttribute("cellpadding", "0");
		tables[i].setAttribute("cellspacing", "0");
	}
}
addLoadEvent(prepareTable);