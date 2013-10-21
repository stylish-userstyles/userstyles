function installGenerator(id) {
	if (window.sidebar && window.sidebar.addMicrosummaryGenerator) {
		window.sidebar.addMicrosummaryGenerator("http://userstyles.org/livetitle/xml/" + id);
	} else {
		alert("You don't seem to have a live title capable browser.");
	}
}

function confirmDelete(name) {
	return confirm("Are you sure you want to delete '" + name + "'?");
}
