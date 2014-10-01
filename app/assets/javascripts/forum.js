(function() {

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
	location.href = document.getElementById("start-discussion").href;
}

function showLogInUI() {
	document.getElementById("login-form").style.display = "";
	document.getElementById("no-discussions").style.display = "none";
}

function addClickEvent(id, fn) {
	var el = document.getElementById(id);
	if (!el)
		return;
	el.addEventListener("click", fn, false);
}

function init() {
	addClickEvent("start-discussion", startDiscussion)
}

function startDiscussion(event) {
	addDiscussion();
	event.preventDefault()
}

if (document.getElementById("post-discussion")) {
	init();
} else {
	window.addEventListener("DOMContentLoaded", init, false);
}

})();
