//##############################################################################
//# YaBB.js                                                                    #
//##############################################################################
//# YaBB: Yet another Bulletin Board                                           #
//# Open-Source Community Software for Webmasters                              #
//# Version:        YaBB 3.0 Beta                                              #
//# Packaged:       October 05, 2010                                           #
//# Distributed by: http://www.yabbforum.com                                   #
//# ===========================================================================#
//# Copyright (c) 2000-2010 YaBB (www.yabbforum.com) - All Rights Reserved.    #
//# Software by:  The YaBB Development Team                                    #
//#               with assistance from the YaBB community.                     #
//##############################################################################

//YaBB 3.0 Beta $Revision: 100 $

// DocClick object for registering multiple document.onclick events
DocClick = new Array();

var ev;
var addQuote;

function DocClicked(e) {
	ev = e;
	if(DocClick != null) {
		for (var i = 0; i < DocClick.length; i++) {
			eval(DocClick[i]);
		}
	}
}

document.onclick = DocClicked;

// Resize the pop up box and it's iframe
function ResizeIFrame(height) {
	var winheight = window.innerHeight === undefined ? document.documentElement.clientHeight : window.innerHeight;
	if (height + 28 > winheight - 22) {
		height = winheight - 50;
	}
	document.getElementById("ImageAlertIFrame").height = height + "px";
	document.getElementById("ImageAlertLoad").style.display = "none";
	var imagealert = document.getElementById("ImageAlert");
	imagealert.style.marginTop = parseInt(-(height + 20) / 2) + "px";
}

function IFrameShrink() {
	document.getElementById("ImageAlertIFrame").height = "0px";
}

// Caps Lock and Not Allowed Characters detection
function capsLock(eve,ident){
	keyCode = eve.keyCode ? eve.keyCode : eve.which;
	shiftKey = eve.shiftKey ? eve.shiftKey : ((keyCode == 16) ? true : false);

	// check for Caps Lock
	if (((keyCode > 64 && keyCode < 91) && !shiftKey)||((keyCode > 96 && keyCode < 123) && shiftKey)) {
		document.getElementById(ident + '_char').style.display = 'none';
		document.getElementById(ident).style.display = 'block';

	} else {
		document.getElementById(ident).style.display = 'none';

		// check for Not Allowed Characters
		character = String.fromCharCode(keyCode);
		if (((keyCode > 31 && keyCode < 127) || keyCode > 159) &&
		    /[^\s\w!@#$%\^&\*\(\)\+\|`~\-=\\:;'",\.\/\?\[\]\{\}]/.test(character)) {
			document.getElementById(ident + '_char').style.display = 'block';
			document.getElementById(ident + '_character').childNodes[0].nodeValue = character;
		} else {
			document.getElementById(ident + '_char').style.display = 'none';
		}
	}
}


//scroll fix for IE
window.onload = function () {
			if (document.all) {
				var codeFix = document.all.tags("div");
				for (var codeI = 0; codeI < codeFix.length; codeI++) {
					if (codeFix[codeI].className == "scroll" && (codeFix[codeI].scrollWidth > codeFix[codeI].clientWidth || codeFix[codeI].clientWidth == 0))
					codeFix[codeI].style.height = (codeFix[codeI].clientHeight + 34) + "px";
				}
			}
		}


// for email decoding
function SpamInator(title,v1,v2,adr,subbody) {
	v2 = unescape(v2); var v3 = '';
	for(var v4 = 0; v4 < v1.length; v4++) { v3 += String.fromCharCode(v1.charCodeAt(v4)^v2.charCodeAt(v4)); }
	if (!title) title = v3;
	document.write('<a href="javascript:void(0)" onclick="window.location=\'' + adr + v3 + subbody + '\'">' + title + '</a>');
}


// for QuickLinks display
var hideTimer = null;
var lastOpen = null;
function quickLinks(num) {
	closeLinks(lastOpen);
	document.getElementById(num).style.display = "inline-block";
	document.getElementById(num).parentNode.style.zIndex = "1000";
	lastOpen = num;
}
function TimeClose(num) {
	hideTimer = setTimeout("closeLinks('"+num+"')", 1000);
}
function keepLinks(num) {
	clearTimeout(hideTimer);
	hideTimer = null;
}
function closeLinks(num) {
	if(lastOpen != null) {
		document.getElementById(num).style.display = "none";
		document.getElementById(num).parentNode.style.zIndex = "0";
	}
	lastOpen = null;
	clearTimeout(hideTimer);
	hideTimer = null;
}

DocClick.push("blurLinks()");

function blurLinks(){
	if(lastOpen != null) {
		var target = (ev && ev.target) || (event && event.srcElement);
		var obj = document.getElementById(lastOpen); 
		var obj2 = obj.parentNode; 
		if (target != obj && target != obj2) { closeLinks(lastOpen); }
	}
} 


// for email
function checkMailaddr(theMailField) {
	if (/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i.test(theMailField)) return true;
	return false;
}


// for attachments
function selectNewattach(file_id) {
	document.getElementById("w_file"+file_id).options[1].selected = true;
}


// for quote buttons
var quote_selection = new Array();

function quoteSelection(quote_name, quote_topic_id, quote_msg_id, quote_date, quote_message) {
	if ((quote_selection[quote_msg_id] && quote_selection[quote_msg_id] != '') || (quote_message && quote_message != '')) {
		if (quote_message) quote_selection[quote_msg_id] = unescape(quote_message);
		AddText('[quote author=' + quote_name + ' link=' + quote_topic_id + '/' + quote_msg_id + '#' + quote_msg_id + ' date=' + quote_date + ']' + quote_selection[quote_msg_id] + '[/quote]\r\n');
		quote_selection[quote_msg_id] = '';
		quote_message = '';
	} else {
		alertqq();
	}
}

function get_selection(msg_id) {
	if (window.getSelection) {
		quote_selection[msg_id] = window.getSelection();
	} else {
		quote_selection[msg_id] = document.selection.createRange().text;
	}
	quote_selection[msg_id] = '' + quote_selection[msg_id] + '';
	// quote_selection[msg_id] = quote_selection[msg_id].replace(/\\r\\n/g, "_caret_");
	// quote_selection[msg_id] = quote_selection[msg_id].replace(/_caret_/g, "\\r\\n");
}

function InsertQuote() {
	if (addQuote && addQuote != "") {
		eval(addQuote);
		addQuote = "";
	}
}

// for image resizing
var noimgdir, noimgtitle;
function resize_images() {
	var tmp_array = new Array ();
	for (var i = 0; i < img_resize_names.length; i++) {
		var tmp_image_name = img_resize_names[i];

		var maxwidth  = 0;
		var maxheight = 0;
		var type = (tmp_image_name.split("_", 1))[0];
		if (type == 'avatar') {
			maxwidth  = avatar_img_w;
			maxheight = avatar_img_h;
		} else if (type == 'post') {
			maxwidth  = post_img_w;
			maxheight = post_img_h;
		} else if (type == 'attach') {
			maxwidth  = attach_img_w;
			maxheight = attach_img_h;
		} else if (type == 'signat') {
			maxwidth  = signat_img_w;
			maxheight = signat_img_h;
		}

		if ((fix_avatar_size && type == 'avatar') || (fix_post_size && type == 'post') || (fix_attach_size && type == 'attach') || (fix_signat_size && type == 'signat')) {
			if (maxwidth)  document.images[tmp_image_name].width  = maxwidth;
			if (maxheight) document.images[tmp_image_name].height = maxheight;
			document.images[tmp_image_name].style.display = 'inline';
			continue;
		}

		if (document.images[tmp_image_name].complete == false) {
			tmp_array[tmp_array.length] = tmp_image_name;
			// The following is needed since Opera does not load/show
			// style.display='none' images if they are not already in chache.
			if (/Opera/i.test(navigator.userAgent)) {
				document.images[tmp_image_name].width  = document.images[tmp_image_name].width  || 0;
				document.images[tmp_image_name].height = document.images[tmp_image_name].height || 0;
				document.images[tmp_image_name].style.display = 'inline';
			}
			continue;
		}

		var tmp_image = new Image;
		tmp_image.src = document.images[tmp_image_name].src;

		var tmpwidth  = document.images[tmp_image_name].width  || tmp_image.width;
		var tmpheight = document.images[tmp_image_name].height || tmp_image.height;

		if (!tmpwidth && !tmpheight) {
			tmp_array[tmp_array.length] = tmp_image_name;
			continue;
		}

		if (maxwidth != 0 && tmpwidth > maxwidth) {
			tmpheight = tmpheight * maxwidth / tmpwidth;
			tmpwidth  = maxwidth;
		}

		if (maxheight != 0 && tmpheight > maxheight) {
			tmpwidth  = tmpwidth * maxheight / tmpheight;
			tmpheight = maxheight;
		}

		document.images[tmp_image_name].width  = tmpwidth;
		document.images[tmp_image_name].height = tmpheight;
		document.images[tmp_image_name].style.display = 'inline';
	}

	if (tmp_array.length > 0 && resize_time < 350) {
		img_resize_names = tmp_array;
		if (resize_time == 290) {
			for (var i = 0; i < img_resize_names.length; i++) {
				var tmp_image_name = img_resize_names[i];
				document.images[tmp_image_name].src = noimgdir + "/noimg.gif";
				document.images[tmp_image_name].title = noimgtitle;
			}
		}
		setTimeout("resize_time++; resize_images();", 100);

	// To prevent window from jumping to other place because
	// of image resize after window is set to the ancor this is needed:
	} else if (location.hash) {
		location.href = location.hash;
	}
}


/***********************************************
* New_News_Fader 1.0
*
* Fades news bi-directionally between any starting and ending color smoothly
*
* Written for YaBB by Eddy
* 14-Jan-2005
* Original 'fader.js' by NRg (allbrowsers_fader.mod v2.02 01/12/2002)
*
* Based upon uni-directional fading code from:
* Fading Scroller- � Dynamic Drive DHTML code library (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code
***********************************************/

var DOM2 = document.getElementById;
var ie4 = document.all && !DOM2;
var fadecounter;
var fcontent = new Array();
var begintag = '';
var closetag = '';

function HexToR(h) { return parseInt((cutHex(h)).substring(0,2),16) }
function HexToG(h) { return parseInt((cutHex(h)).substring(2,4),16) }
function HexToB(h) { return parseInt((cutHex(h)).substring(4,6),16) }
function cutHex(h) { return (h.charAt(0)=="#") ? h.substring(1,7) : h}

function changecontent() {
	if (index >= fcontent.length) index = 0;

	if (DOM2) {
		document.getElementById("fscroller").style.color="rgb("+startcolor[0]+", "+startcolor[1]+", "+startcolor[2]+")";
		document.getElementById("fscroller").innerHTML=begintag+fcontent[index]+closetag;
		if (fadelinks) linkcolorchange(1);
		colorfadeup(1);
	} else if (ie4) {
		document.all.fscroller.innerHTML=begintag+fcontent[index]+closetag;
	}
	index++;
}

function linkcolorchange(step) {
	var obj = document.getElementById("fscroller").getElementsByTagName("A");
	if (obj.length > 0) {
		for (i = 0; i < obj.length; i++) { 
			obj[i].style.color=getstepcolor(step);
		}
	}
}

function colorfadeup(step) {
	if (step <= maxsteps) {
		document.getElementById("fscroller").style.color = getstepcolor(step);
		if (fadelinks) linkcolorchange(step);
		step++;
		fadecounter = setTimeout("colorfadeup("+step+")", stepdelay);
	} else {
		clearTimeout(fadecounter);
		document.getElementById("fscroller").style.color = "rgb("+endcolor[0]+", "+endcolor[1]+", "+endcolor[2]+")";
		setTimeout("colorfadedown("+maxsteps+")", delay);
	}
}

function colorfadedown(step) {
	if (step > 1) {
		step--;
		document.getElementById("fscroller").style.color = getstepcolor(step);
		if (fadelinks) linkcolorchange(step);
		fadecounter = setTimeout("colorfadedown("+step+")", stepdelay);
	} else {
		clearTimeout(fadecounter);
		document.getElementById("fscroller").style.color = "rgb("+startcolor[0]+", "+startcolor[1]+", "+startcolor[2]+")";
		setTimeout("changecontent()", delay / 2);
	}
}

function getstepcolor(step) {
	var diff;
	var newcolor = new Array(3);
	for (var i = 0; i < 3; i++) {
		diff = (startcolor[i] - endcolor[i]);
		if (diff > 0) newcolor[i] = startcolor[i] - (Math.round((diff/maxsteps))*step);
		else newcolor[i] = startcolor[i] + (Math.round((Math.abs(diff)/maxsteps))*step);
	}
	return ("rgb(" + newcolor[0] + ", " + newcolor[1] + ", " + newcolor[2] + ")");
}


// Dynamic clock
function WriteClock(Element_Id,s1,s2) {
	if (OurTime == 0) return;

	returnTime = Clock(s2);

	if (document.getElementById(Element_Id) && document.getElementById(Element_Id).childNodes) {
		document.getElementById(Element_Id).childNodes[0].nodeValue = s1 + returnTime;
	} else if (document.all) {
		document.all[Element_Id].innerHTML = s1 + returnTime;
	} else if (document.Element_Id && window.netscape && window.screen) {
		document.Element_Id.document.open();
		document.Element_Id.document.write(s1 + returnTime);
		document.Element_Id.document.close();
	} else {
		document.write(s1 + returnTime);
		return;
	}

	setTimeout("WriteClock('" + Element_Id + "','" + s1 + "','" + s2 + "')", 1000);
}

function Clock(ampm) {
	OurTime = new Date();
	OurTime = OurTime.getTime() - TimeDif;
	YaBBTime.setTime(OurTime);
	var sec  = YaBBTime.getSeconds();
	var min  = YaBBTime.getMinutes();
	var hour = YaBBTime.getHours();
	if (sec  < 10) sec  = "0" + sec;
	if (min  < 10) min  = "0" + min;
	if (hour < 10) hour = "0" + hour;
	if (ampm) {
		if (ampm == ' ') return (hour + ":" + min);
		hour = hour % 12 || 12;
		return (hour + ":" + min + ampm);
	}
	return (hour + ":" + min + ":" + sec);
}