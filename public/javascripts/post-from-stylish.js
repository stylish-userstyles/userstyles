function postFromStylish(event) {
	//only do this if it's not filled in (it could be filled in if the user went through all this and got an error)
	if (document.getElementById("css").value || document.getElementById("style_short_description").value) {
		return;
	}
	var stylishEvent = document.createEvent("Events");
	stylishEvent.initEvent("postFromStylish", false, false, window, null);
	document.dispatchEvent(stylishEvent);
}
document.addEventListener("DOMContentLoaded", postFromStylish, false);

function postFromStylishReturn(event) {
	var data = eval(document.getElementById("stylish-info").value);
	document.getElementById("css").value = data.code;
	document.getElementById("style_short_description").value = data.shortDescription;
}
document.addEventListener("postFromStylishReturn", postFromStylishReturn, false);
