$(document).ready(function() {
	// automatically click the jsconnect links if they're there
	setTimeout(function() {
		if ($('#dashboard_entry_signin .ConnectLink').length == 1) {
			$('#dashboard_entry_signin .ConnectLink')[0].click();
			return;
		}
		if ($('#dashboard_entry_signin .JsConnect-Guest .SignInLink').length == 1) {
			$('#dashboard_entry_signin .JsConnect-Guest .SignInLink')[0].click();
			return;
		}
	}, 1000);

	// https://github.com/vanilla/addons/issues/93
	// Change signout link to main site signout
	var signoutLink = $('.SignOutWrap a');
	signoutLink.attr('href', 'https://userstyles.org/logout');
});
