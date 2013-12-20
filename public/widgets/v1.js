var userstyles = {
	itemTemplate: "<li><a href=\"${url}\" target=\"_new\"><span class=\"userstyles-style-name\">${name}</span><br><span class=\"userstyles-style-info\">${weekly_installs} installs this week</span></a></li>",

	handleData: function(data) {
		var replacements = this.itemTemplate.match(/\$\{[a-z_]+\}/g);
		var container = document.getElementById("userstyles-container");
		var ul = document.createElement("ul");
		var allHtml = "";
		for (var i = 0; i < data.length; i++) {
			var itemHtml = this.itemTemplate;
			for (var j = 0; j < replacements.length; j++) {
				var property = this.stripTemplateMarkers(replacements[j]);
				if (property in data[i]) {
					var value = data[i][property];
					if (typeof value == "number") {
						value = this.formatNumber(value);
					}
					itemHtml = itemHtml.replace(new RegExp("\\$\\{" + property + "\\}", "g"), this.escapeHtml(value));
				}
			}
			allHtml += itemHtml;
		}
		ul.innerHTML = allHtml;
		this.addStylesheet();
		container.appendChild(ul);
	},

	escapeHtml: function(html) {
		if (typeof html != "string") {
			return html;
		}
		return html.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
	},

	stripTemplateMarkers: function(s) {
		return s.substring(2, s.length - 1);
	},

	formatNumber: function(num) {
		var numStr = "" + num;
		var remainder = numStr.length % 3;
		var f = numStr.substr(0, remainder);
		for (var i = remainder; i < numStr.length; i += 3) {
			if (f != "") {
				f += ",";
			}
			f += numStr.substr(i, 3);
		}
		return f;
	},

	addStylesheet: function() {
		var s = document.createElement("style");
		s.setAttribute("type", "text/css");
		var css = "#userstyles-container {width: 160px;font-size: 14px;overflow: hidden;}#userstyles-container h3 {margin-top: 5px;margin-bottom: 5px;}#userstyles-container ul {list-style-type: none;margin: 0;padding: 0;}#userstyles-container li a {display: block;color: black;text-decoration: none;padding: 3px 5px 0 5px;}#userstyles-container .userstyles-style-name {text-decoration: underline;}#userstyles-container .userstyles-style-info {font-size: 12px;color: green;}";
		if (s.styleSheet) {
			s.styleSheet.cssText = css;
		} else {
			s.appendChild(document.createTextNode(css));
		}
		var heads = document.getElementsByTagName('head');
		var ip = document.head || document.getElementsByTagName('head')[0] || document.documentElement || document.firstChild;
		ip.appendChild(s);
	}
}
