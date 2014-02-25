(function() {

function asyncScript(url) {
	var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
	po.src = url;
	var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
};
window.addEventListener('load', function() {
	asyncScript('//connect.facebook.net/en_US/all.js#xfbml=1');
	asyncScript('https://apis.google.com/js/plusone.js');
	asyncScript('https://platform.twitter.com/widgets.js');
	asyncScript("//assets.pinterest.com/js/pinit.js");
}, false);

})();
