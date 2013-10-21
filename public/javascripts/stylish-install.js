function getId() {
	return document.getElementById("style-id").innerHTML;
}
function toggleCode() {
	var showButton = document.getElementById("show-button");
	if (showButton.innerHTML == "Show code") {
		loadCode(function() {
			document.getElementById("view-code").style.display = "block";
			showButton.innerHTML = "Hide code";
		}, true);
	} else {
		hideCode();
	}
}
function hideCode() {
	var showButton = document.getElementById("show-button");
	document.getElementById("view-code").style.display = "none";
	showButton.innerHTML = "Show code";
}
function initShowCode() {
	var showButton = document.getElementById("show-button");
	addEvent(showButton, "click", toggleCode);
	showButton.style.display = "inline";

}
function initEditCode() {
	var controlPanel = document.getElementById("control-panel");
	var userIdStart = document.cookie.indexOf("user_id");
	if (userIdStart > -1) {
		var userId = document.cookie.substring(userIdStart + 8, document.cookie.indexOf(";", userIdStart));
		var styleUserId = document.getElementById("user-id").innerHTML;
		if (userId == styleUserId) {
			controlPanel.style.display = "block";
		}
	}
}
function init() {
	initInstall();
	initShowCode();
	initEditCode();
}

if (window.addEventListener)
	window.addEventListener("DOMContentLoaded", init, false);
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
	if ("textContent" in codeElement)
		text = codeElement.textContent;
	else
		text = codeElement.innerText;
	if (text.length > 0 && options == currentOptions) {
		if (callback) {
			callback();
		}
		return false;
	}
	var xhr = new XMLHttpRequest();
	xhr.open('GET', '/styles/' + getId() + '.css' + (options == "" ? "" : "?" + options), true);
	xhr.onreadystatechange = function(event) {
		if (xhr.readyState == 4) {
			if (xhr.status == 200) {
				if ("textContent" in codeElement)
					codeElement.textContent = xhr.responseText;
				else
					codeElement.innerText = xhr.responseText;
				currentOptions = options;
				if (callback)
					callback();
			} else {
				throw 'Sorry, an error occurred loading the code - status ' + xhr.status + '.';
			}
			document.body.style.cursor = "";
		}
	}
	document.body.style.cursor = "wait";
	xhr.send(null);
	return true;
}

function getOptions(promptOnIncomplete) {
	var params = [];
	var names = [];
	var styleOptions = document.getElementById("style-options");
	if (!styleOptions) {
		return "";
	}	
	var inputs = styleOptions.getElementsByTagName("input");
	for (var i = 0; i < inputs.length; i++) {
		if (names.indexOf(inputs[i].name) == -1) {
			names.push(inputs[i].name);
		}
		if (inputs[i].checked) {
			params.push(inputs[i].name + "=" + inputs[i].value);
		}
	}
	if (names.length != params.length) {
		if (promptOnIncomplete) {
			alert("Choose a value for every setting first.");
		}
		return null;
	}
	return params.join("&");
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
function stylishInstallChrome(event) {
	var options = getOptions(true);
	if (options != null) {
		var link = document.querySelector("link[rel='stylish-code-chrome']");
		var url = link.href.split("?")[0];
		if (options != "") {
			link.setAttribute("href", url + "?" + options);
		} else {
			link.setAttribute("href", url);
		}
		fireCustomEvent("stylishInstallChrome");
	}
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

var currentPanel = "style-install-unknown";
function switchToPanel(panelId) {
	document.getElementById(currentPanel).style.display = "none";
	document.getElementById(panelId).style.display = "";
	currentPanel = panelId;
}

function switchBrowserValue(value) {
	var select = document.getElementById("switch-browser");
	var options = select.getElementsByTagName("option");
	for (var i = 0; i < options.length; i++) {
		if (options[i].value == value) {
			options[i].selected = true;
			return;
		}
	}
}

function hideBrowserSwitcher() {
	document.getElementById("switch-browser").style.display = "none";
}

//stylish will fire this after the user installs or updates
function styleInstalled() {
	if (BrowserDetect.browser == "Explorer") 
		switchToPanel("stylish-installed-style-installed-ie");
	else
		switchToPanel("stylish-installed-style-installed");
	hideBrowserSwitcher();
}
function styleInstalledChrome() {
	switchToPanel("stylish-installed-style-installed-chrome");
	hideBrowserSwitcher();
}

//stylish will fire these on load
function styleCanBeInstalled(event) {
	if (!event && BrowserDetect.browser == "Explorer")
		switchToPanel("stylish-installed-style-not-installed-ie");
	else {
		switchToPanel("stylish-installed-style-not-installed");
	}
	hideBrowserSwitcher();
}
function styleCanBeInstalledChrome(event) {
	switchToPanel("stylish-installed-style-not-installed-chrome");
	hideBrowserSwitcher();
}
function styleAlreadyInstalled() {
	styleInstalled();
}
function styleAlreadyInstalledChrome() {
	styleInstalledChrome();
}
function styleCanBeUpdated() {
	switchToPanel("stylish-installed-style-needs-update");
	hideBrowserSwitcher();
}

//fires on page load
function initInstall() {
	// make sure Stylish didn't already change this
	if (currentPanel != "style-install-unknown") {
		return;
	}
	document.getElementById("switch-browser").style.display = "";
	switch (BrowserDetect.browser) {
		case "Chrome":
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
addCustomEventListener("styleAlreadyInstalled", styleAlreadyInstalled);
addCustomEventListener("styleAlreadyInstalledChrome", styleAlreadyInstalledChrome);
addCustomEventListener("styleCanBeInstalled", styleCanBeInstalled);
addCustomEventListener("styleCanBeInstalledChrome", styleCanBeInstalledChrome);
addCustomEventListener("styleCanBeUpdated", styleCanBeUpdated);
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
			switchToPanel("style-install-ie");
			break;
		case "mozilla":
			switchToPanel("style-install-mozilla-no-stylish");
			break;
		case "opera":
			switchToPanel("style-install-opera");
			break;
		case "chrome":
			switchToPanel("style-install-chrome");
			break;
		case "mobilesafariandroid":
			switchToPanel("style-install-mobile-safari-android");
			break;
		case "other":
			switchToPanel("style-install-unknown");
			break;
	}
}
