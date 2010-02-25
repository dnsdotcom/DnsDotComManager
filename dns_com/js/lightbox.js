/*
Taken From::
	Created By: Chris Campbell
	Website: http://particletree.com
	Date: 2/1/2006

	Inspired by the lightbox implementation found at http://www.huddletogether.com/projects/lightbox/

Modified By::
	Brian Smith - DNZoom
*/

/*-------------------------------GLOBAL VARIABLES------------------------------------*/

var detect = navigator.userAgent.toLowerCase();
var OS,browser,version,total,thestring;

/*-----------------------------------------------------------------------------------------------*/

//Browser detect script origionally created by Peter Paul Koch at http://www.quirksmode.org/

function getBrowserInfo() {
	if (checkIt('konqueror')) {
		browser = "Konqueror";
		OS = "Linux";
	}
	else if (checkIt('safari')) browser = "Safari";
	else if (checkIt('omniweb')) browser = "OmniWeb";
	else if (checkIt('opera')) browser = "Opera";
	else if (checkIt('webtv')) browser = "WebTV";
	else if (checkIt('icab')) browser = "iCab";
	else if (checkIt('msie')) browser = "Internet Explorer";
	else if (!checkIt('compatible')) {
		browser = "Netscape Navigator"
		version = detect.charAt(8);
	}
	else browser = "An unknown browser";

	if (!version) version = detect.charAt(place + thestring.length);

	if (!OS) {
		if (checkIt('linux')) OS = "Linux";
		else if (checkIt('x11')) OS = "Unix";
		else if (checkIt('mac')) OS = "Mac"
		else if (checkIt('win')) OS = "Windows"
		else OS = "an unknown operating system";
	}
}

function checkIt(string) {
	place = detect.indexOf(string) + 1;
	thestring = string;
	return place;
}

/*-----------------------------------------------------------------------------------------------*/

$(window).one('load', getBrowserInfo);
$(window).one('load', addLightboxMarkup);
//Event.observe(window, 'unload', Event.unloadCache, false);

var Lightbox = {
	content : '',

	yPos : 0,
	xPos : 0,

	hOrig : 0,
	wOrig : 0,

	// specific for confirm
	callback : '',
	callbackArgs : '',


	// Turn everything on - mainly the IE fixes
	activate: function(){
		Lightbox.prepare();
		return Lightbox.displayLightbox("block");
	},

	prepare: function() {
		if (browser == 'Internet Explorer'){
			Lightbox.getScroll();
			Lightbox.prepareIE('100%', 'hidden');
			Lightbox.setScroll(0,0);
// 			Lightbox.hideSelects('hidden');
		}
		return true;
	},

	// Ie requires height to 100% and overflow hidden or else you can scroll down past the lightbox
	prepareIE: function(height, overflow) {
		bod = $(document.getElementsByTagName('body')[0]);
		bod.height(height);
		bod.css('overflow', overflow);

		htm = $(document.getElementsByTagName('html')[0]);
		htm.height(height);
		htm.css('overflow', overflow);
		return true;
	},

	// In IE, select elements hover on top of the lightbox
	hideSelects: function(visibility){
		selects = document.getElementsByTagName('select');
		for(i = 0; i < selects.length; i++) {
			$(selects[i]).css('visibility', visibility);
		}
		return true;
	},

	// Taken from lightbox implementation found at http://www.huddletogether.com/projects/lightbox/
	getScroll: function(){
		if (self.pageYOffset) {
			Lightbox.yPos = self.pageYOffset;
		} else if (document.documentElement && document.documentElement.scrollTop){
			Lightbox.yPos = document.documentElement.scrollTop;
		} else if (document.body) {
			Lightbox.yPos = document.body.scrollTop;
		}
		return true;
	},

	setScroll: function(x, y){
		window.scrollTo(x, y);
		return true;
	},

	setDimensions: function(h,w) {
		$('#lightbox').height(parseInt(h));
		$('#lightbox').width( parseInt(w));
		return true;
	},

	displayLightbox: function(display){
		$('#overlay').css('display',  display);
		$('#lightbox').css('display', display);

		if (display == 'block') {
			var theDiv = "<div id=\"lbContent\"></div>";
			$('#lbLoadMessage').before(theDiv);
			return Lightbox.content = $('#lbContent');
		}
	},

	// Example of creating your own functionality once lightbox is initiated
	deactivate: function() {
		$('#lbContent').remove();

		if (browser == "Internet Explorer"){
			Lightbox.setScroll(0,Lightbox.yPos);
			Lightbox.prepareIE("auto", "auto");
// 			Lightbox.hideSelects("visible");
		}

		Lightbox.displayLightbox("none");

		$('#lightbox').height(Lightbox.hOrig);
		$('#lightbox').width( Lightbox.wOrig);

		Lightbox.callback = '';
		Lightbox.callbackArgs = '';
		return false;
	},

/*------------------------------ NOTICE BOXES ---------------------------------------------------*/
	alert: function(msg) {
		Lightbox.setDimensions(380,630);

		Lightbox.activate();
		Lightbox.content.append('<div style="padding:12px 15px;"><center><div style="width:100px;height:20px;text-align:center"><span class="left" style="margin-right:5px"><img src="/images/alert.png"></span><span class="left"><h2>Alert</h2></span></div></center>'
		+ '<br /><p>'+msg.toString()+'</p><br />'
		+ '<a href="javascript:void();" onClick="javascript:return Lightbox.deactivate();" class="actionbutton"><span>Continue</span></a></div>');
		return true;
	},
	
	display: function(page, title, disable_actions) {
		Lightbox.setDimensions(380,630);
		if (! title)
			title = 'Help notice';
		
		Lightbox.activate();
		Lightbox.content.append('<div style="padding:12px 15px;"><center><h2>'+title+'</h2></center>'
		+ '<br /><p id="displayDiv"></p><br />'
		+ ((! disable_actions) ? '<p><a href="javascript:void();" onClick="javascript:return Lightbox.deactivate();">OK</a>' : '' ) +'</p></div>');
		
		$('#displayDiv').load(page);
		return true;
	},

	confirm : function(msg, callback, args) {
		Lightbox.callback = callback;
		Lightbox.callbackArgs = args;

		Lightbox.setDimensions(380,630);
		Lightbox.activate();
		
		Lightbox.content.append('<div style="padding:12px 15px;"><center><div style="width:180px;height:20px;text-align:center"><span class="left" style="margin-right:5px"><img src="/images/confirmicon.png"></span><span class="left"><h2>Please confirm</h2></span></div></center>'
		+ '<br /><p>'+msg.toString()+'</p><br />'
		+ '<a href="#" onClick="javascript:return Lightbox.confirmResponse();" class="actionbutton"><span>Yes</span></a>'
		+ '<a href="#" onClick="javascript:return Lightbox.deactivate();" class="actionbutton"><span>No</span></a></div>');
		return true;
	},

	confirmResponse : function() {
		Lightbox.callback( Lightbox.callbackArgs );
		Lightbox.deactivate();
		return true;
	}
};

/*-----------------------------------------------------------------------------------------------*/

// Add in markup necessary to make this work. Basically two divs:
// Overlay holds the shadow
// Lightbox is the centered square that the content is put into.
function addLightboxMarkup() {
	$('body').append('<div id="overlay"><div id="lightbox" class="loading"><div id="lbLoadMessage"><p>Loading</p></div></div></div>');
	Lightbox.hOrig = $('#lightbox').height();
	Lightbox.wOrig = $('#lightbox').width();
	return true;
}
