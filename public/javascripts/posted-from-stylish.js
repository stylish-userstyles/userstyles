function postedFromStylish(event) {
	var stylishEvent = document.createEvent("Events");
	stylishEvent.initEvent("postedFromStylish", false, false, window, null);
	document.dispatchEvent(stylishEvent);
}
document.addEventListener("DOMContentLoaded", postedFromStylish, false);
