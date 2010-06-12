//##############################################################################
//# ajax.js                                                                    #
//##############################################################################
//# YaBB: Yet another Bulletin Board                                           #
//# Open-Source Community Software for Webmasters                              #
//# Version:        YaBB 2.4                                                   #
//# Packaged:       April 12, 2009                                             #
//# Distributed by: http://www.yabbforum.com                                   #
//# ===========================================================================#
//# Copyright (c) 2000-2009 YaBB (www.yabbforum.com) - All Rights Reserved.    #
//# Software by:  The YaBB Development Team                                    #
//#               with assistance from the YaBB community.                     #
//# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com           #
//#               Your source for web hosting, web design, and domains.        #
//##############################################################################

//YaBB 2.4 $Revision$

var xmlHttp = null;
var browser = '';
var imagedir = '';

if (navigator.appName == "Microsoft Internet Explorer") {
	browser = "block"; 
} else {
	browser = "table"; 
}

function Collapse_All (url,action,imgdir,lng) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url + ";oldcollapse=1";
		return;
	}

	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);

	var i = 0;
	var noboards = "";
	var boards = "";
	var imgsrc = "";
	if (action == 1) { 
		boards = browser;
		noboards = "none";
		imgsrc = "/cat_collapse.gif";
		document.getElementById("expandall").style.display = "none";
		document.getElementById("collapseall").style.display = "";
	} else {
		noboards = "";
		boards = "none";
		imgsrc = "/cat_expand.gif";
		document.getElementById("expandall").style.display = "";
		document.getElementById("collapseall").style.display = "none";
	}

	for (i = 0 ; i < catNames.length; i++) {
		document.getElementById(catNames[i]).style.display = boards;
		document.getElementById("col"+catNames[i]).style.display = noboards;
		document.getElementById("img"+catNames[i]).src = imgdir + imgsrc;
		document.getElementById("img"+catNames[i]).title = lng;
		document.getElementById("img"+catNames[i]).alt = lng;
	}
}

function SendRequest (url,cat,imgdir,lng_collapse,lng_expand) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url + ";oldcollapse=1";
		return;
	}

	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);

	var open = 0;
	var closed = 0;
	var board = '';
	if (document.getElementById(cat).style.display == "none") {
		document.getElementById(cat).style.display = browser;
		document.getElementById("col"+cat).style.display = "none";
		document.getElementById("img"+cat).src = imgdir+"/cat_collapse.gif";
		document.getElementById("img"+cat).title = lng_collapse;
		document.getElementById("img"+cat).alt = lng_collapse;
		document.getElementById("collapseall").style.display = "";
	} else {
		document.getElementById(cat).style.display = "none";
		document.getElementById("col"+cat).style.display = "";
		document.getElementById("img"+cat).src = imgdir+"/cat_expand.gif";
		document.getElementById("img"+cat).title = lng_expand;
		document.getElementById("img"+cat).alt = lng_expand;
		document.getElementById("expandall").style.display = "";
	}
	for (i = 0; i < catNames.length; i++) {
		if (document.getElementById(catNames[i]).style.display == "none") { closed++; }
		else { open++; }
	}
	if (closed == catNames.length) {
		document.getElementById("collapseall").style.display = "none";
		document.getElementById("expandall").style.display = "";
	}
	if (open == catNames.length) {
		document.getElementById("collapseall").style.display = "";
		document.getElementById("expandall").style.display = "none";
	}
}

function MarkAllAsRead(url,imgdir) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url + ";oldmarkread=1";
		return;
	}
	imagedir = imgdir;
	var imagealert = document.getElementById("ImageAlert");
	imagealert.style.visibility = "visible";
	document.getElementById("ImageAlertText").innerHTML = markallreadlang;
	document.getElementById("ImageAlertPic").innerHTML = '<img src="' + imagedir + '/Rotate.gif">';
	xmlHttp.onreadystatechange=MarkFinished;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}

function MarkFinished() {
	if (xmlHttp.readyState==4 || xmlHttp.readyState=="complete") { 
		document.getElementById("ImageAlertText").innerHTML = markfinishedlang;
		document.getElementById("ImageAlertPic").innerHTML = '<img src="' + imagedir + '/RotateStop.gif">';
		setTimeout("HideAlert()",1500);
		var images = document.getElementsByTagName("img");
		for (var i=0; i<images.length; i++) {
			var src = images[i].getAttribute("src");
			if (src.match("/on.gif") && !images[i].id.match("no_edit")) {
				images[i].setAttribute("src",src.replace("/on.gif","/off.gif"));
			}
			if (src.match("imclose.gif")) {
				images[i].setAttribute("src",src.replace("imclose.gif","imopen.gif"));
			}
			if (src.match("imclose2.gif")) {
				images[i].setAttribute("src",src.replace("imclose2.gif","imopen2.gif"));
			}
			if (src.match("new.gif")) {
				images[i].style.display = "none";
			}
		}
		var newlinks = document.getElementsByTagName("span");
		for (var e=0; e<newlinks.length; e++) {
			if (newlinks[e].className == "NewLinks") {
				newlinks[e].style.display = "none";
			}
		}
 	} 
}

function AddRemFav(url,imgdir) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url + ";oldaddfav=1";
		return;
	}
	imagedir = imgdir;
	var imagealert = document.getElementById("ImageAlert");
	imagealert.style.visibility = "visible";
	if (url.match("addfav")) {
		document.getElementById("ImageAlertText").innerHTML = addfavlang;
		if(document.postmodify != null) { document.postmodify.favorite.checked = 'checked'; }
	} else {
		document.getElementById("ImageAlertText").innerHTML = remfavlang;
		if(document.postmodify != null) { document.postmodify.favorite.checked = ''; }
	}
	document.getElementById("ImageAlertPic").innerHTML = '<img src="' + imagedir + '/Rotate.gif">';
	xmlHttp.onreadystatechange=AddRemFavFinished;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}


function AddRemFavFinished() {
	if (xmlHttp.readyState == 4 || xmlHttp.readyState == "complete") {
		document.getElementById("ImageAlertText").innerHTML = markfinishedlang;
		document.getElementById("ImageAlertPic").innerHTML = '<img src="' + imagedir + '/RotateStop.gif">';
		setTimeout("HideAlert()",1500);
		var links = document.getElementsByName("favlink");
		for (var i = 0; i < links.length; i++) {
			var href = links[i].href;
			if (href.match("addfav")) {
				links[i].setAttribute("href",href.replace("addfav","remfav"));
				links[i].innerHTML = remlink;
			}
			if (href.match("remfav")) {
				links[i].setAttribute("href",href.replace("remfav","addfav"));
				links[i].innerHTML = addlink;
			}
		}
 	}
}

function Notify(url,imgdir) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url + ";oldnotify=1";
		return;
	}
	imagedir = imgdir;
	var imagealert = document.getElementById("ImageAlert");
	imagealert.style.visibility = "visible";
	if (url.match("notify2")) {
		document.getElementById("ImageAlertText").innerHTML = addnotelang;
		if(document.postmodify != null) { document.postmodify.notify.checked = 'checked'; }
	} else {
		document.getElementById("ImageAlertText").innerHTML = remnotelang;
		if(document.postmodify != null) { document.postmodify.notify.checked = ''; }
	}
	document.getElementById("ImageAlertPic").innerHTML = '<img src="' + imagedir + '/Rotate.gif">';
	xmlHttp.onreadystatechange=NotifyFinished;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}

function NotifyFinished() {
	if (xmlHttp.readyState == 4 || xmlHttp.readyState == "complete") {
		document.getElementById("ImageAlertText").innerHTML = markfinishedlang;
		document.getElementById("ImageAlertPic").innerHTML = '<img src="' + imagedir + '/RotateStop.gif">';
		setTimeout("HideAlert()",1500);
		var links = document.getElementsByName("notifylink");
		for (var i = 0; i < links.length; i++) {
			var href = links[i].href;
			if (href.match("notify2")) {
				links[i].setAttribute("href",href.replace("notify2","notify3"));
				links[i].innerHTML = remnotlink;
			}
			if (href.match("notify3")) {
				links[i].setAttribute("href",href.replace("notify3","notify2"));
				links[i].innerHTML = addnotlink;
			}
		}
 	} 
}

//---------------
// Member Search
//---------------
var list = new Array();
var list2 = new Array();
var first = "";

function LetterChange(text) {
	text = text.toLowerCase()
	if (text.length == 1) {
		if (list[text] == null) {
			first = text;
			SendLetter(text);
		} else {
			first = text;
			ListNames(list[text],list2[text]);
		}
	} else if (text.length > 1) {
		var temp = new Array();
		var temp2 = new Array();
		for(var i = 0; i < list[first].length; i++) {
			text = text.toLowerCase();
			var regex = new RegExp("^" + text);
			if(list[first][i].toLowerCase().match(regex)) {
				temp[temp.length] = list[first][i];
				temp2[temp2.length] = list2[first][i];
			}
		}
		ListNames(temp,temp2);
	}
}

function SendLetter(letter) {
	GetXmlHttpObject();
	if (xmlHttp == null) { alert("AJAX not supported."); return; }
	document.getElementById("load").src = imageurl + "/mozilla_blu.gif";
	xmlHttp.onreadystatechange=Response;
	xmlHttp.open("GET", scripturl + "?action=qsearch2;letter=" + letter, true);
	xmlHttp.send(null);
}

function Response() {
	if (xmlHttp.readyState==4 || xmlHttp.readyState=="complete") { 
		document.getElementById("load").src = imageurl + "/mozilla_gray.gif";
		var results = new Array();
		document.getElementById("response").innerHTML = xmlHttp.responseText;
		list[first] = new Array();
		list2[first] = new Array();
		var temp = new Array();
		temp = document.getElementById("response").innerHTML.split(",");
		for (var i = 0; i < temp.length; i++) {
			if ((i % 2) == 0) { list[first][list[first].length] = temp[i]; }
			else { list2[first][list2[first].length] = temp[i]; }
		}
		if (list[first] == "") { list[first] = new Array(); }
		ListNames(list[first],list2[first]);
	}
}

function ListNames(names,ids) {
		var select = document.getElementById("rec_list");
		select.options.length = 0;
		for (var i = 0; i < names.length; i++) {
			browserAdd(names[i],ids[i]);
		}
		if (select.options.length == 0) { browserAdd(noresults,""); }
}

function browserAdd(name,value) {
	var select = document.getElementById("rec_list");
	if (navigator.appName == "Microsoft Internet Explorer") {
		select.add(new Option(name,value));
	} else {
		select.add(new Option(name,value),null);
	}
}
// End Member Search

// Check username availability
function checkAvail(scripturl,val,type) {
	GetXmlHttpObject();
	if (xmlHttp == null) { alert("AJAX not supported."); return; }
	xmlHttp.onreadystatechange=returnAvail;
	xmlHttp.open("GET", scripturl + "?action=checkavail;type=" + type + ";" + type + "=" + val, true);
	xmlHttp.send(null);
}

function returnAvail() {
     if (xmlHttp.readyState==4 || xmlHttp.readyState=="complete") {
 	    var avail = xmlHttp.responseText;
 	    var type = avail.split("|");
 	    document.getElementById(type[0] + "availability").innerHTML = type[1]; }
}

function HideAlert() {
	document.getElementById("ImageAlert").style.visibility = "hidden";
}

function GetXmlHttpObject() {
	try { // test if ajax is supported
		if (typeof( new XMLHttpRequest() ) == 'object') {
			xmlHttp = new XMLHttpRequest();
		} else if (typeof( new ActiveXObject("Msxml2.XMLHTTP") ) == 'object') {
			xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
		} else if (typeof( new ActiveXObject("Microsoft.XMLHTTP") ) == 'object') {
			xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
	} catch (e) { }
}