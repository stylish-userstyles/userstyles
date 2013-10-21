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
window.addEventListener("DOMContentLoaded", showAppropriateUIForParameter, false);
