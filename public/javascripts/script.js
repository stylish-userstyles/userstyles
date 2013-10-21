// http://www.quirksmode.org/js/detect.html
var BrowserDetect = {
	init: function () {
		this.browser = this.searchString(this.dataBrowser) || "An unknown browser";
		this.version = this.searchVersion(navigator.userAgent)
			|| this.searchVersion(navigator.appVersion)
			|| "an unknown version";
		this.OS = this.searchString(this.dataOS) || "an unknown OS";
	},
	searchString: function (data) {
		for (var i=0;i<data.length;i++)	{
			var dataString = data[i].string;
			var dataProp = data[i].prop;
			this.versionSearchString = data[i].versionSearch || data[i].identity;
			if (dataString) {
				if (dataString.indexOf(data[i].subString) != -1)
					return data[i].identity;
			}
			else if (dataProp)
				return data[i].identity;
		}
	},
	searchVersion: function (dataString) {
		var index = dataString.indexOf(this.versionSearchString);
		if (index == -1) return;
		return parseFloat(dataString.substring(index+this.versionSearchString.length+1));
	},
	dataBrowser: [
		// added by me!
		{
			string: navigator.userAgent,
			subString: "OPR",
			versionSearch: "OPR/",
			identity: "Opera"
		},
		{
			string: navigator.userAgent,
			subString: "Chrome",
			identity: "Chrome"
		},
		{ 	string: navigator.userAgent,
			subString: "OmniWeb",
			versionSearch: "OmniWeb/",
			identity: "OmniWeb"
		},
		{
			string: navigator.vendor,
			subString: "Apple",
			identity: "Safari",
			versionSearch: "Version"
		},
		{
			prop: window.opera,
			identity: "Opera"
		},
		{
			string: navigator.vendor,
			subString: "iCab",
			identity: "iCab"
		},
		{
			string: navigator.vendor,
			subString: "KDE",
			identity: "Konqueror"
		},
		{
			string: navigator.userAgent,
			subString: "Firefox",
			identity: "Firefox"
		},
		{
			string: navigator.vendor,
			subString: "Camino",
			identity: "Camino"
		},
		{		// for newer Netscapes (6+)
			string: navigator.userAgent,
			subString: "Netscape",
			identity: "Netscape"
		},
		{
			string: navigator.userAgent,
			subString: "MSIE",
			identity: "Explorer",
			versionSearch: "MSIE"
		},
		{
			string: navigator.userAgent,
			subString: "Gecko",
			identity: "Mozilla",
			versionSearch: "rv"
		},
		{ 		// for older Netscapes (4-)
			string: navigator.userAgent,
			subString: "Mozilla",
			identity: "Netscape",
			versionSearch: "Mozilla"
		}
	],
	dataOS : [
		{
			string: navigator.platform,
			subString: "Win",
			identity: "Windows"
		},
		{
			string: navigator.platform,
			subString: "Mac",
			identity: "Mac"
		},
		{
			   string: navigator.userAgent,
			   subString: "iPhone",
			   identity: "iPhone/iPod"
	    },
		{
			string: navigator.platform,
			subString: "Linux",
			identity: "Linux"
		}
	]

};
BrowserDetect.init();






// ------- Discussions

function addDiscussion() {
	var postDiscussion = document.getElementById("post-discussion")
	if (postDiscussion.hasChildNodes()) {
		location.href = "#post-discussion";
		return;
	}
	var xhr = new XMLHttpRequest();
	xhr.open('GET', '/login/check', true);
	xhr.onreadystatechange = function(event) {
		try {
			if (xhr.readyState == 4) {
				if (xhr.status == 200) {
					if (xhr.responseText == "logged in") {
						showAddDiscussionUI();
					} else {
						showLogInUI();
					}
				} else {
					alert('Sorry, an error occurred checking to see if you\'re logged in.');
				}
				document.body.style.cursor = "";
			}
		} catch (ex) {
			alert("Sorry, an error occurred.");
			throw ex;
		}
	}
	document.body.style.cursor = "wait";
	xhr.send(null);
}

function showAddDiscussionUI() {
	var iframe = document.createElement("iframe");
	iframe.setAttribute("id", "add-review");
	iframe.setAttribute("src", document.getElementById("start-discussion").href + "&minimal=true");
	document.getElementById("post-discussion").appendChild(iframe);
	location.href = "#post-discussion";
}

function showLogInUI() {
	document.getElementById("login-form").style.display = "";
}

function showAppropriateUIForParameter() {
	if (location.hash == "#post-discussion") {
		addDiscussion();
	}
}
if (window.addEventListener) {
	window.addEventListener("DOMContentLoaded", showAppropriateUIForParameter, false);
} else {
	addEvent(window, "load", showAppropriateUIForParameter);
}



// ------- Installs
var currentPanel = "style-install-unknown";

function getId() {
	return document.getElementById("style-id").innerHTML;
}
function toggleCode(event) {
	var showButton = document.getElementById("show-button");
	if (showButton.innerHTML == "Show CSS") {
		loadCode(function() {
			document.getElementById("view-code").style.display = "block";
			showButton.innerHTML = "Hide CSS";
		}, true);
	} else {
		hideCode();
	}
	event.preventDefault();
}
function hideCode() {
	var showButton = document.getElementById("show-button");
	document.getElementById("view-code").style.display = "none";
	showButton.innerHTML = "Show CSS";
}
function initShowCode() {
	var showButton = document.getElementById("show-button");
	addEvent(showButton, "click", toggleCode);
	showButton.style.display = "inline";

}
function initEditCode() {
	var controlPanel = document.getElementById("control-panel");
	var styleUserId = document.getElementById("user-id").innerHTML;
	var userId = getUserFromCookie();
	if (userId == styleUserId) {
		controlPanel.style.display = "block";
	}
}
function init() {
	initShowCode();
	initEditCode();
	// update these links with the default values
	updateNonStylishInstallLinks();
}

if (window.addEventListener)
	window.addEventListener("load", init, false);
else
	window.onload = init;

var currentOptions = null;
function loadCode(callback, promptOnIncomplete) {
	var codeElement = document.getElementById('stylish-code');
	var text;
	var options = getOptions(promptOnIncomplete);
	if (options == null) {
		return false;
	}
	var optionsString = toQueryString(options);
	if ("textContent" in codeElement)
		text = codeElement.textContent;
	else
		text = codeElement.innerText;
	if (text.length > 0 && optionsString == currentOptions) {
		if (callback) {
			callback();
		}
		return false;
	}
	var longOptions = optionsString.length > 2000;
	var xhr = new XMLHttpRequest();
	if (longOptions) {
		xhr.open('POST', '/styles/' + getId() + '.css', true);
		xhr.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	} else {
		xhr.open('GET', '/styles/' + getId() + '.css' + (optionsString == "" ? "" : "?" + optionsString), true);
	}
	xhr.onreadystatechange = function(event) {
		if (xhr.readyState == 4) {
			if (xhr.status == 200) {
				if ("textContent" in codeElement)
					codeElement.textContent = xhr.responseText;
				else
					codeElement.innerText = xhr.responseText;
				currentOptions = optionsString;
				if (callback)
					callback();
			} else {
				throw 'Sorry, an error occurred loading the code - status ' + xhr.status + '.';
			}
			document.body.style.cursor = "";
		}
	}
	document.body.style.cursor = "wait";
	if (longOptions) {
		xhr.send(optionsString);
	} else {
		xhr.send(null);
	}
	return true;
}

function getOptions(promptOnIncomplete) {
	var styleOptions = document.getElementById("style-options");
	if (!styleOptions) {
		return [];
	}	
	// dropdown
	var selects = styleOptions.getElementsByTagName("select");
	var params = [];
	for (var i = 0; i < selects.length; i++) {
			params.push([selects[i].name, selects[i].value]);
	}
	var missingSettings = [];
	// color
	var inputs = styleOptions.querySelectorAll("input[type='text']");
	for (var i = 0; i < inputs.length; i++) {
			if (inputs[i].value == "") {
				missingSettings.push(inputs[i]);
			} else {
				params.push([inputs[i].name, inputs[i].value]);
			}
	}
	// image
	inputs = styleOptions.querySelectorAll("input[type='radio']:checked");
	for (var i = 0; i < inputs.length; i++) {
		switch (inputs[i].value) {
			case "user-url":
				var idParts = inputs[i].name.split("-");
				var id = "option-user-url-" + idParts[idParts.length - 1];
				var userInput = document.getElementById(id);
				if (userInput.value == '') {
					missingSettings.push(userInput.parentNode);
				} else {
					params.push([inputs[i].name, userInput.value]);
				}
				break;
			case "user-upload":
				var idParts = inputs[i].name.split("-");
				var id = "option-user-upload-" + idParts[idParts.length - 1];
				var userInput = document.getElementById(id);
				if (!userInput.uploadedData) {
					missingSettings.push(userInput.parentNode);
				} else {
					params.push([inputs[i].name, userInput.uploadedData]);
				}
				break;
			default:
				params.push([inputs[i].name, inputs[i].value]);
				break;
		}
	}

	if (missingSettings.length > 0) {
		if (promptOnIncomplete) {
			alert("Choose a value for every setting first.");
			//settings[i].input.parentNode.scrollIntoView();
			missingSettings[0].scrollIntoView();
			setTimeout(function () {
				for (var i = 0; i < missingSettings.length; i++) {
					new Effect.Highlight(missingSettings[i], {endcolor: "#7CCD7C"});
				}
			}, 500);
		}
		return null;
	}

	return params;
}

function toQueryString(optionsArray) {
	return optionsArray.map(function(a) {
		return a[0] + "=" + encodeURIComponent(a[1]);
	}).join("&");
}

function loadUpload(input) {
	var oFile = input.files[0];  
	if (input.files.length === 0) {
		input.uploadedData = null;
	}
	var oFReader = new FileReader()
	oFReader.onload = function (oFREvent) {  
		input.uploadedData = oFREvent.target.result;
	}; 
	oFReader.readAsDataURL(oFile);
}

//we fire these to tell stylish what to do
function stylishInstall(event) {
	loadCode(stylishInstall2, true);
}
function stylishInstall2() {
	fireCustomEvent("stylishInstall");
}
function stylishInstallIE(event) {
	fireCustomEvent("stylishInstall");
}

function updateLinkThenFire(linkRel, eventName) {
	var options = getOptions(true);
	if (options != null) {
		var link = document.querySelector("link[rel='" + linkRel + "']");
		var url = link.href.split("?")[0];
		link.setAttribute("href", url + "?" + toQueryString(options));
		fireCustomEvent(eventName);
	}
}

function stylishInstallChrome(event) {
	updateLinkThenFire("stylish-code-chrome", "stylishInstallChrome");
}
function stylishUpdateChrome(event) {
	updateLinkThenFire("stylish-code-chrome", "stylishUpdateChrome");
}
function stylishInstallOpera(event) {
	updateLinkThenFire("stylish-code-opera", "stylishInstallOpera");
}
function stylishUpdateOpera(event) {
	updateLinkThenFire("stylish-code-opera", "stylishUpdateOpera");
}

function stylishUpdate() {
	loadCode(stylishUpdate2, true);
}
function stylishUpdate2() {
	var stylishEvent = document.createEvent("Events");
	stylishEvent.initEvent("stylishUpdate", false, false, window, null);
	document.dispatchEvent(stylishEvent);
}

function fireCustomEvent(name) {
	if (document.createEvent) {
		var stylishEvent = document.createEvent("Events");
		stylishEvent.initEvent(name, false, false, window, null);
		document.dispatchEvent(stylishEvent);
	} else {
		var communicationElement = document.getElementById("stylish-event-element");
		communicationElement.setAttribute("stylish-data", name);
		communicationElement.click();
	}
};

var stylishActivatedPanel = null;
function switchToPanel(panelId) {
	document.getElementById(currentPanel).style.display = "none";
	document.getElementById(panelId).style.display = "";
	currentPanel = panelId;
}

function switchBrowserValue(value) {
	var select = document.getElementById("switch-browser");
	if (select) {
		var options = select.getElementsByTagName("option");
		for (var i = 0; i < options.length; i++) {
			if (options[i].value == value) {
				options[i].selected = true;
				return;
			}
		}
	}
}

//stylish will fire this after the user installs or updates
function styleInstalled() {
	if (BrowserDetect.browser == "Explorer") {
		genericStyleInstalled("stylish-installed-style-installed-ie");
	} else {
		genericStyleInstalled("stylish-installed-style-installed");
	}
}
function styleInstalledChrome() {
	genericStyleInstalled("stylish-installed-style-installed-chrome");
}
function styleInstalledOpera() {
	genericStyleInstalled("stylish-installed-style-installed-opera");
}
function genericStyleInstalled(panel) {
	switchToPanel(panel);
	addAdToInstallBox(panel);
	stylishActivatedPanel = panel;
}


function userStyleInstall(link) {
	var options = getOptions(true);
	if (options == null) {
		return false;
	}
	var baseUrl = link.href.split("?")[0];
	setTimeout(function() {
		addAdToInstallBox(link.parentNode.parentNode.id);
	}, 3000);
	// if it's too long, do a post instead
	var optionsString = toQueryString(options);
	if (optionsString.length > 2000) {
		setTimeout(function() {
			fakeFormSubmit(baseUrl, options);
		}, 250);
		return false;
	}
	// add parameters to the url, but we need to end with .user.js
	link.href = baseUrl + (optionsString == "" ? "" : "?" + optionsString + "&.user.js");
	return true;
}

function fakeFormSubmit(url, options) {
	// get the POST url - /styles/userjs/ID. this will avoid the GM trigger as it does not support POST params
	document.body.style.cursor = "wait";
	urlParts = url.split("/");
	url = "/styles/userjs/" + urlParts[urlParts.length - 2];
	var form = document.createElement("form");
	form.style.display = "none";
	form.setAttribute("method", "POST");
	form.setAttribute("action", url);
	for (var i = 0; i < options.length; i++) {
		var input = document.createElement("input");
		input.name = options[i][0];
		input.value = options[i][1];
		form.appendChild(input);
	}
	var submit = document.createElement("input");
	submit.type = "submit";
	form.appendChild(submit);
	document.body.appendChild(form);
	submit.click();
	document.body.style.cursor = "";
}

function updateNonStylishInstallLinks() {
	var options = getOptions(false);
	if (options == null) {
		return;
	}
	var optionsString = toQueryString(options);
	var links = document.querySelectorAll(".alternate-install");
	for (var i = 0; i < links.length; i++) {
		var currentUrl = links[i].getAttribute("href");
		var currentUrlParts = currentUrl.split("?");
		if (currentUrlParts.length > 1) {
			currentUrl = currentUrlParts[0];
		}
		links[i].setAttribute("href", currentUrl + ((optionsString == "" || optionsString.length > 2000) ? "" : "?" + optionsString));
	}
}

function addAdToInstallBox(installBoxId) {
	var pia = document.getElementById("post-install-ad");
	var installBox = document.getElementById(installBoxId);
	if (pia.className == "afterdownload-ad") {
		installBox.appendChild(pia);
		pia.style.display = "";
	} else {
		var placeholder = document.createElement("div");
		// matches ad size, plus 12 on height for padding
		placeholder.style.width = "300px";
		placeholder.style.height = "262px";
		installBox.appendChild(placeholder);
		pia.style.top = placeholder.offsetTop + "px";
		pia.style.left = placeholder.offsetLeft + "px";
		pia.style.position = "absolute";
		pia.style.display = "block";
	}
}

//stylish will fire these on load
function styleCanBeInstalled(event) {
	if (!event && BrowserDetect.browser == "Explorer") {
		genericStyleCanBeInstalled("stylish-installed-style-not-installed-ie");
	} else {
		genericStyleCanBeInstalled("stylish-installed-style-not-installed");
	}
}
function styleCanBeInstalledChrome(event) {
	genericStyleCanBeInstalled("stylish-installed-style-not-installed-chrome");
}
function styleCanBeInstalledOpera(event) {
	genericStyleCanBeInstalled("stylish-installed-style-not-installed-opera");
}
function genericStyleCanBeInstalled(panel) {
	switchToPanel(panel);
	stylishActivatedPanel = panel;
}

function styleAlreadyInstalled() {
	styleInstalled();
}
function styleAlreadyInstalledChrome() {
	styleInstalledChrome();
}
function styleAlreadyInstalledOpera() {
	styleInstalledOpera();
}

function styleCanBeUpdated() {
	genericStyleCanBeUpdated("stylish-installed-style-needs-update");
}
function styleCanBeUpdatedChrome() {
	genericStyleCanBeUpdated("stylish-installed-style-needs-update-chrome");
}
function styleCanBeUpdatedOpera() {
	genericStyleCanBeUpdated("stylish-installed-style-needs-update-opera");
}
function genericStyleCanBeUpdated(panel) {
	switchToPanel(panel);
	stylishActivatedPanel = panel;
}

function initInstall() {
	// make sure Stylish didn't already change this
	if (currentPanel != "style-install-unknown") {
		return;
	}
	var switchBrowser = document.getElementById("switch-browser");
	if (switchBrowser) {
		switchBrowser.parentNode.style.display = "";
	}
	switch (BrowserDetect.browser) {
		case "Chrome":
			// mobile chrome can't do this yet
			if (navigator.userAgent.indexOf("Android") > -1) {
				switchToPanel("style-install-mobile-chrome-android");
				switchBrowserValue("mobilechromeandroid");
				break;
			}
			switchToPanel("style-install-chrome");
			switchBrowserValue("chrome");
			break;
		case "Opera":
			switchToPanel("style-install-opera");
			switchBrowserValue("opera");
			break;
		case "Explorer":
			switchToPanel("style-install-ie");
			switchBrowserValue("ie");
			break;
		case "Mozilla":
			// this thing thinks safari on android is mozilla
			if (navigator.userAgent.indexOf("Safari") > -1 && navigator.userAgent.indexOf("Android") > -1) {
				switchToPanel("style-install-mobile-safari-android");
				switchBrowserValue("mobilesafariandroid");
				break;
			}
			// if not, fallthrough
		case "Firefox":
		case "Netscape":
			switchToPanel("style-install-mozilla-no-stylish");
			switchBrowserValue("mozilla");
			break;
		default:
			switchBrowserValue("other");
	}
}
// run immediately
initInstall();

function addCustomEventListener(name, f) {
	if (document.addEventListener) {
		document.addEventListener(name, f, false);
	} 
	else {
		if (listenerMappings == null) {
			// The right way to do it, but it doesn't work... It will just call this directly
			//document.getElementById("stylish-event-element").attachEvent("onclick", handleCustomEvent);
			listenerMappings = {};
		}
		listenerMappings[name] = f;
	}
}

var listenerMappings = null;
function handleCustomEvent() {
	var communicationElement = document.getElementById("stylish-event-element");
	var f = listenerMappings[communicationElement.getAttribute("stylish-data")];
	if (f)
		f();
}

function addEvent(element, name, f) {
	if (element.addEventListener) {
		element.addEventListener(name, f, false);
	} else {
		element.attachEvent("on" + name, f);
	}
}

addCustomEventListener("styleInstalled", styleInstalled);
addCustomEventListener("styleInstalledChrome", styleInstalledChrome);
addCustomEventListener("styleInstalledOpera", styleInstalledOpera);
addCustomEventListener("styleAlreadyInstalled", styleAlreadyInstalled);
addCustomEventListener("styleAlreadyInstalledChrome", styleAlreadyInstalledChrome);
addCustomEventListener("styleAlreadyInstalledOpera", styleAlreadyInstalledOpera);
addCustomEventListener("styleCanBeInstalled", styleCanBeInstalled);
addCustomEventListener("styleCanBeInstalledChrome", styleCanBeInstalledChrome);
addCustomEventListener("styleCanBeInstalledOpera", styleCanBeInstalledOpera);
addCustomEventListener("styleCanBeUpdated", styleCanBeUpdated);
addCustomEventListener("styleCanBeUpdatedChrome", styleCanBeUpdatedChrome);
addCustomEventListener("styleCanBeUpdatedOpera", styleCanBeUpdatedOpera);
addCustomEventListener("styleLoadCode", function() {
	if (!loadCode(codeLoaded, false)) {
		// if this returns false, then it has options. if the user has it installed (even with different options), mark it as installed
		styleInstalled();
	}
});

function codeLoaded() {
	var stylishEvent = document.createEvent("Events");
	stylishEvent.initEvent("stylishCodeLoaded", false, false, window, null);
	document.dispatchEvent(stylishEvent);
}

function switchBrowser(select) {
	switch (select.value) {
		case "ie":
			if (stylishActivatedPanel == "stylish-installed-style-installed-ie" || stylishActivatedPanel == "stylish-installed-style-not-installed-ie") {
				switchToPanel(stylishActivatedPanel);
			} else {
				switchToPanel("style-install-ie");
			}
			break;
		case "mozilla":
			if (stylishActivatedPanel == "stylish-installed-style-installed" || stylishActivatedPanel == "stylish-installed-style-not-installed" || stylishActivatedPanel == "stylish-installed-style-needs-update") {
				switchToPanel(stylishActivatedPanel);
			} else {
				switchToPanel("style-install-mozilla-no-stylish");
			}
			break;
		case "opera":
			if (stylishActivatedPanel == "stylish-installed-style-installed-opera" || stylishActivatedPanel == "stylish-installed-style-not-installed-opera" || stylishActivatedPanel == "stylish-installed-style-needs-update-opera") {
				switchToPanel(stylishActivatedPanel);
			} else {
				switchToPanel("style-install-opera");
			}
			break;
		case "chrome":
			if (stylishActivatedPanel == "stylish-installed-style-installed-chrome" || stylishActivatedPanel == "stylish-installed-style-not-installed-chrome" || stylishActivatedPanel == "stylish-installed-style-needs-update-chrome") {
				switchToPanel(stylishActivatedPanel);
			} else {
				switchToPanel("style-install-chrome");
			}
			break;
		case "mobilesafariandroid":
			switchToPanel("style-install-mobile-safari-android");
			break;
		case "mobilechromeandroid":
			switchToPanel("style-install-mobile-chrome-android");
			break;
		case "other":
			switchToPanel("style-install-unknown");
			break;
	}
}

// foxlingo install thingy
function guide(imgUrl) {
	var body = document.getElementsByTagName("body")[0];
	var div = document.createElement("div");
	div.setAttribute("class", "install-bg")
	body.appendChild(div);
	var div_container = document.createElement("div");
	div_container.setAttribute("class", "install-bag")
	var img = document.getElementById("install-img");
	if (!img) {
		img = document.createElement("img");
		img.setAttribute("src", imgUrl);
		img.setAttribute("class", "install-img")
		img.setAttribute("id", "install-img")
		img.addEventListener("mousedown",function(e) { body.removeChild(div); div_container.removeChild(e.currentTarget); },false);
		div_container.appendChild(img);
		img.style.display ="block"
		body.appendChild(div_container);
		var baseMargin = 10;
		if (BrowserDetect.version != "3.6") {
			// Fx 4, doorhanger
			img.setAttribute("style", "float: none; margin-left: 60px");
			baseMargin = 135;
		}
		img.style.marginTop = (document.documentElement.scrollTop+12 + baseMargin) + "px"
	}
	var interval;
	var opacity = 0;
	var opacityDelta = 0.03
	var sizeInterval = function(div) {
		opacity += opacityDelta;
		div.style['opacity'] = opacity;
		finalOpacity = 0.8;
		if (div.id=="install-img")
		finalOpacity = 1
		if (opacity>=finalOpacity) {
			clearInterval(interval)
			interval = null;
			if (div.id!="install-img") {
				opacity = 0;
				interval = setInterval(sizeInterval, 1, img);
			}
		}
	}
	interval = setInterval(sizeInterval, 1, div);
} 

/*
* downloadParams = {"AddonFox":downloadLink, "AddonFox":downloadLink}
*/
function install (aEvent, downloadParams,img) {
    InstallTrigger.install(downloadParams);
	if (BrowserDetect.browser == "Firefox") {
	    guide(img);
	}
    return false;
}

// -----------------------------------------------------------------------------------
//
//	Lightbox v2.05
//	by Lokesh Dhakar - http://www.lokeshdhakar.com
//	Last Modification: 3/18/11
//
//	For more information, visit:
//	http://lokeshdhakar.com/projects/lightbox2/
//
//	Licensed under the Creative Commons Attribution 2.5 License - http://creativecommons.org/licenses/by/2.5/
//  	- Free for use in both personal and commercial projects
//		- Attribution requires leaving author name, author link, and the license info intact.
//	
//  Thanks: Scott Upton(uptonic.com), Peter-Paul Koch(quirksmode.com), and Thomas Fuchs(mir.aculo.us) for ideas, libs, and snippets.
//  		Artemy Tregubenko (arty.name) for cleanup and help in updating to latest ver of proto-aculous.
//
// -----------------------------------------------------------------------------------
/*

    Table of Contents
    -----------------
    Configuration

    Lightbox Class Declaration
    - initialize()
    - updateImageList()
    - start()
    - changeImage()
    - resizeImageContainer()
    - showImage()
    - updateDetails()
    - updateNav()
    - enableKeyboardNav()
    - disableKeyboardNav()
    - keyboardAction()
    - preloadNeighborImages()
    - end()
    
    Function Calls
    - document.observe()
   
*/
// -----------------------------------------------------------------------------------

//
//  Configurationl
//
LightboxOptions = Object.extend({
    fileLoadingImage:        'http://cdn.userstyles.org/images/loading.gif',     
    fileBottomNavCloseImage: 'http://cdn.userstyles.org/images/closelabel.gif',

    overlayOpacity: 0.8,   // controls transparency of shadow overlay

    animate: true,         // toggles resizing animations
    resizeSpeed: 7,        // controls the speed of the image resizing animations (1=slowest and 10=fastest)

    borderSize: 10,         //if you adjust the padding in the CSS, you will need to update this variable

	// When grouping images this is used to write: Image # of #.
	// Change it for non-english localization
	labelImage: "Image",
	labelOf: "of"
}, window.LightboxOptions || {});

// -----------------------------------------------------------------------------------

var Lightbox = Class.create();

Lightbox.prototype = {
    imageArray: [],
    activeImage: undefined,
    
    // initialize()
    // Constructor runs on completion of the DOM loading. Calls updateImageList and then
    // the function inserts html at the bottom of the page which is used to display the shadow 
    // overlay and the image container.
    //
    initialize: function() {    
        
        this.updateImageList();
        
        this.keyboardAction = this.keyboardAction.bindAsEventListener(this);

        if (LightboxOptions.resizeSpeed > 10) LightboxOptions.resizeSpeed = 10;
        if (LightboxOptions.resizeSpeed < 1)  LightboxOptions.resizeSpeed = 1;

	    this.resizeDuration = LightboxOptions.animate ? ((11 - LightboxOptions.resizeSpeed) * 0.15) : 0;
	    this.overlayDuration = LightboxOptions.animate ? 0.2 : 0;  // shadow fade in/out duration

        // When Lightbox starts it will resize itself from 250 by 250 to the current image dimension.
        // If animations are turned off, it will be hidden as to prevent a flicker of a
        // white 250 by 250 box.
        var size = (LightboxOptions.animate ? 250 : 1) + 'px';
        

        // Code inserts html at the bottom of the page that looks similar to this:
        //
        //  <div id="overlay"></div>
        //  <div id="lightbox">
        //      <div id="outerImageContainer">
        //          <div id="imageContainer">
        //              <img id="lightboxImage">
        //              <div style="" id="hoverNav">
        //                  <a href="#" id="prevLink"></a>
        //                  <a href="#" id="nextLink"></a>
        //              </div>
        //              <div id="loading">
        //                  <a href="#" id="loadingLink">
        //                      <img src="images/loading.gif">
        //                  </a>
        //              </div>
        //          </div>
        //      </div>
        //      <div id="imageDataContainer">
        //          <div id="imageData">
        //              <div id="imageDetails">
        //                  <span id="caption"></span>
        //                  <span id="numberDisplay"></span>
        //              </div>
        //              <div id="bottomNav">
        //                  <a href="#" id="bottomNavClose">
        //                      <img src="images/close.gif">
        //                  </a>
        //              </div>
        //          </div>
        //      </div>
        //  </div>


        var objBody = $$('body')[0];

		objBody.appendChild(Builder.node('div',{id:'overlay'}));
	
        objBody.appendChild(Builder.node('div',{id:'lightbox'}, [
            Builder.node('div',{id:'outerImageContainer'}, 
                Builder.node('div',{id:'imageContainer'}, [
                    Builder.node('img',{id:'lightboxImage'}), 
                    Builder.node('div',{id:'hoverNav'}, [
                        Builder.node('a',{id:'prevLink', href: '#' }),
                        Builder.node('a',{id:'nextLink', href: '#' })
                    ]),
                    Builder.node('div',{id:'loading'}, 
                        Builder.node('a',{id:'loadingLink', href: '#' }, 
                            Builder.node('img', {src: LightboxOptions.fileLoadingImage})
                        )
                    )
                ])
            ),
            Builder.node('div', {id:'imageDataContainer'},
                Builder.node('div',{id:'imageData'}, [
                    Builder.node('div',{id:'imageDetails'}, [
                        Builder.node('span',{id:'caption'}),
                        Builder.node('span',{id:'numberDisplay'})
                    ]),
                    Builder.node('div',{id:'bottomNav'},
                        Builder.node('a',{id:'bottomNavClose', href: '#' },
                            Builder.node('img', { src: LightboxOptions.fileBottomNavCloseImage })
                        )
                    )
                ])
            )
        ]));


		$('overlay').hide().observe('click', (function() { this.end(); }).bind(this));
		$('lightbox').hide().observe('click', (function(event) { if (event.element().id == 'lightbox') this.end(); }).bind(this));
		$('outerImageContainer').setStyle({ width: size, height: size });
		$('prevLink').observe('click', (function(event) { event.stop(); this.changeImage(this.activeImage - 1); }).bindAsEventListener(this));
		$('nextLink').observe('click', (function(event) { event.stop(); this.changeImage(this.activeImage + 1); }).bindAsEventListener(this));
		$('loadingLink').observe('click', (function(event) { event.stop(); this.end(); }).bind(this));
		$('bottomNavClose').observe('click', (function(event) { event.stop(); this.end(); }).bind(this));

        var th = this;
        (function(){
            var ids = 
                'overlay lightbox outerImageContainer imageContainer lightboxImage hoverNav prevLink nextLink loading loadingLink ' + 
                'imageDataContainer imageData imageDetails caption numberDisplay bottomNav bottomNavClose';   
            $w(ids).each(function(id){ th[id] = $(id); });
        }).defer();
    },

    //
    // updateImageList()
    // Loops through anchor tags looking for 'lightbox' references and applies onclick
    // events to appropriate links. You can rerun after dynamically adding images w/ajax.
    //
    updateImageList: function() {   
        this.updateImageList = Prototype.emptyFunction;

        document.observe('click', (function(event){
			if ((event.button && event.button != 0) || (event.ctrlKey || event.shiftKey || event.altKey || event.metaKey)) {
				return;
			}
            var target = event.findElement('a[rel^=lightbox]') || event.findElement('area[rel^=lightbox]');
            if (target) {
                event.stop();
                this.start(target);
            }
        }).bind(this));
    },
    
    //
    //  start()
    //  Display overlay and lightbox. If image is part of a set, add siblings to imageArray.
    //
    start: function(imageLink) {    

        $$('select', 'object', 'embed').each(function(node){ node.style.visibility = 'hidden' });

        // stretch overlay to fill page and fade in
        var arrayPageSize = this.getPageSize();
        $('overlay').setStyle({ width: arrayPageSize[0] + 'px', height: arrayPageSize[1] + 'px' });

        new Effect.Appear(this.overlay, { duration: this.overlayDuration, from: 0.0, to: LightboxOptions.overlayOpacity });

        this.imageArray = [];
        var imageNum = 0;       

        if ((imageLink.getAttribute("rel") == 'lightbox')){
            // if image is NOT part of a set, add single image to imageArray
            this.imageArray.push([imageLink.href, imageLink.title]);         
        } else {
            // if image is part of a set..
            this.imageArray = 
                $$(imageLink.tagName + '[href][rel="' + imageLink.rel + '"]').
                collect(function(anchor){ return [anchor.href, anchor.title]; }).
                uniq();
            
            while (this.imageArray[imageNum][0] != imageLink.href) { imageNum++; }
        }

        // calculate top and left offset for the lightbox 
        var arrayPageScroll = document.viewport.getScrollOffsets();
        var lightboxTop = arrayPageScroll[1] + (document.viewport.getHeight() / 10);
        var lightboxLeft = arrayPageScroll[0];
        this.lightbox.setStyle({ top: lightboxTop + 'px', left: lightboxLeft + 'px' }).show();
        
        this.changeImage(imageNum);
    },

    //
    //  changeImage()
    //  Hide most elements and preload image in preparation for resizing image container.
    //
    changeImage: function(imageNum) {   
        
        this.activeImage = imageNum; // update global var

        // hide elements during transition
        if (LightboxOptions.animate) this.loading.show();
        this.lightboxImage.hide();
        this.hoverNav.hide();
        this.prevLink.hide();
        this.nextLink.hide();
		// HACK: Opera9 does not currently support scriptaculous opacity and appear fx
        this.imageDataContainer.setStyle({opacity: .0001});
        this.numberDisplay.hide();      
        
        var imgPreloader = new Image();
        
        // once image is preloaded, resize image container
        imgPreloader.onload = (function(){
            this.lightboxImage.src = this.imageArray[this.activeImage][0];
            /*Bug Fixed by Andy Scott*/
            this.lightboxImage.width = imgPreloader.width;
            this.lightboxImage.height = imgPreloader.height;
            /*End of Bug Fix*/
            this.resizeImageContainer(imgPreloader.width, imgPreloader.height);
        }).bind(this);
        imgPreloader.src = this.imageArray[this.activeImage][0];
    },

    //
    //  resizeImageContainer()
    //
    resizeImageContainer: function(imgWidth, imgHeight) {

        // get current width and height
        var widthCurrent  = this.outerImageContainer.getWidth();
        var heightCurrent = this.outerImageContainer.getHeight();

        // get new width and height
        var widthNew  = (imgWidth  + LightboxOptions.borderSize * 2);
        var heightNew = (imgHeight + LightboxOptions.borderSize * 2);

        // scalars based on change from old to new
        var xScale = (widthNew  / widthCurrent)  * 100;
        var yScale = (heightNew / heightCurrent) * 100;

        // calculate size difference between new and old image, and resize if necessary
        var wDiff = widthCurrent - widthNew;
        var hDiff = heightCurrent - heightNew;

        if (hDiff != 0) new Effect.Scale(this.outerImageContainer, yScale, {scaleX: false, duration: this.resizeDuration, queue: 'front'}); 
        if (wDiff != 0) new Effect.Scale(this.outerImageContainer, xScale, {scaleY: false, duration: this.resizeDuration, delay: this.resizeDuration}); 

        // if new and old image are same size and no scaling transition is necessary, 
        // do a quick pause to prevent image flicker.
        var timeout = 0;
        if ((hDiff == 0) && (wDiff == 0)){
            timeout = 100;
            if (Prototype.Browser.IE) timeout = 250;   
        }

        (function(){
            this.prevLink.setStyle({ height: imgHeight + 'px' });
            this.nextLink.setStyle({ height: imgHeight + 'px' });
            this.imageDataContainer.setStyle({ width: widthNew + 'px' });

            this.showImage();
        }).bind(this).delay(timeout / 1000);
    },
    
    //
    //  showImage()
    //  Display image and begin preloading neighbors.
    //
    showImage: function(){
        this.loading.hide();
        new Effect.Appear(this.lightboxImage, { 
            duration: this.resizeDuration, 
            queue: 'end', 
            afterFinish: (function(){ this.updateDetails(); }).bind(this) 
        });
        this.preloadNeighborImages();
    },

    //
    //  updateDetails()
    //  Display caption, image number, and bottom nav.
    //
    updateDetails: function() {
    
        this.caption.update(this.imageArray[this.activeImage][1]).show();

        // if image is part of set display 'Image x of x' 
        if (this.imageArray.length > 1){
            this.numberDisplay.update( LightboxOptions.labelImage + ' ' + (this.activeImage + 1) + ' ' + LightboxOptions.labelOf + '  ' + this.imageArray.length).show();
        }

        new Effect.Parallel(
            [ 
                new Effect.SlideDown(this.imageDataContainer, { sync: true, duration: this.resizeDuration, from: 0.0, to: 1.0 }), 
                new Effect.Appear(this.imageDataContainer, { sync: true, duration: this.resizeDuration }) 
            ], 
            { 
                duration: this.resizeDuration, 
                afterFinish: (function() {
	                // update overlay size and update nav
	                var arrayPageSize = this.getPageSize();
	                this.overlay.setStyle({ width: arrayPageSize[0] + 'px', height: arrayPageSize[1] + 'px' });
	                this.updateNav();
                }).bind(this)
            } 
        );
    },

    //
    //  updateNav()
    //  Display appropriate previous and next hover navigation.
    //
    updateNav: function() {

        this.hoverNav.show();               

        // if not first image in set, display prev image button
        if (this.activeImage > 0) this.prevLink.show();

        // if not last image in set, display next image button
        if (this.activeImage < (this.imageArray.length - 1)) this.nextLink.show();
        
        this.enableKeyboardNav();
    },

    //
    //  enableKeyboardNav()
    //
    enableKeyboardNav: function() {
        document.observe('keydown', this.keyboardAction); 
    },

    //
    //  disableKeyboardNav()
    //
    disableKeyboardNav: function() {
        document.stopObserving('keydown', this.keyboardAction); 
    },

    //
    //  keyboardAction()
    //
    keyboardAction: function(event) {
        var keycode = event.keyCode;

        var escapeKey;
        if (event.DOM_VK_ESCAPE) {  // mozilla
            escapeKey = event.DOM_VK_ESCAPE;
        } else { // ie
            escapeKey = 27;
        }

        var key = String.fromCharCode(keycode).toLowerCase();
        
        if (key.match(/x|o|c/) || (keycode == escapeKey)){ // close lightbox
            this.end();
        } else if ((key == 'p') || (keycode == 37)){ // display previous image
            if (this.activeImage != 0){
                this.disableKeyboardNav();
                this.changeImage(this.activeImage - 1);
            }
        } else if ((key == 'n') || (keycode == 39)){ // display next image
            if (this.activeImage != (this.imageArray.length - 1)){
                this.disableKeyboardNav();
                this.changeImage(this.activeImage + 1);
            }
        }
    },

    //
    //  preloadNeighborImages()
    //  Preload previous and next images.
    //
    preloadNeighborImages: function(){
        var preloadNextImage, preloadPrevImage;
        if (this.imageArray.length > this.activeImage + 1){
            preloadNextImage = new Image();
            preloadNextImage.src = this.imageArray[this.activeImage + 1][0];
        }
        if (this.activeImage > 0){
            preloadPrevImage = new Image();
            preloadPrevImage.src = this.imageArray[this.activeImage - 1][0];
        }
    
    },

    //
    //  end()
    //
    end: function() {
        this.disableKeyboardNav();
        this.lightbox.hide();
        new Effect.Fade(this.overlay, { duration: this.overlayDuration });
        $$('select', 'object', 'embed').each(function(node){ node.style.visibility = 'visible' });
    },

    //
    //  getPageSize()
    //
    getPageSize: function() {
	        
	     var xScroll, yScroll;
		
		if (window.innerHeight && window.scrollMaxY) {	
			xScroll = window.innerWidth + window.scrollMaxX;
			yScroll = window.innerHeight + window.scrollMaxY;
		} else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
			xScroll = document.body.scrollWidth;
			yScroll = document.body.scrollHeight;
		} else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
			xScroll = document.body.offsetWidth;
			yScroll = document.body.offsetHeight;
		}
		
		var windowWidth, windowHeight;
		
		if (self.innerHeight) {	// all except Explorer
			if(document.documentElement.clientWidth){
				windowWidth = document.documentElement.clientWidth; 
			} else {
				windowWidth = self.innerWidth;
			}
			windowHeight = self.innerHeight;
		} else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
			windowWidth = document.documentElement.clientWidth;
			windowHeight = document.documentElement.clientHeight;
		} else if (document.body) { // other Explorers
			windowWidth = document.body.clientWidth;
			windowHeight = document.body.clientHeight;
		}	

		// for small pages with total height less then height of the viewport
		if(yScroll < windowHeight){
			pageHeight = windowHeight;
		} else { 
			pageHeight = yScroll;
		}
	
		// for small pages with total width less then width of the viewport
		if(xScroll < windowWidth){	
			pageWidth = xScroll;		
		} else {
			pageWidth = windowWidth;
		}

		return [pageWidth,pageHeight];
	}
}

document.observe('dom:loaded', function () { new Lightbox(); });
