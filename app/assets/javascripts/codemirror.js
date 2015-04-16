window.addEventListener("DOMContentLoaded", function() {
	codeMirror = null;

	// Switching between editor and textarea
	$('input.enable-source-editor').change(function(e) {
		var textboxId = e.target.getAttribute("data-related-editor");
		var textbox = document.getElementById(textboxId);
		if (e.target.checked) {
			var targetHeight = getComputedStyle(textbox).height;
			var targetWidth = getComputedStyle(textbox).width;
			codeMirror = CodeMirror.fromTextArea(textbox, {
				lineNumbers: true,
				mode: "css"
			});
			codeMirror.setSize(targetWidth, targetHeight);
			// If the textbox started empty, and the user only used CodeMirror,
			// it will only get a value when submitting. Submitting will be
			// cancelled if it has no value.
			textbox.removeAttribute("required");
		} else {
			var editorElement = document.querySelector(".CodeMirror");
			if (editorElement) {
				codeMirror.toTextArea();
				textbox.setAttribute("required", "required");
			}
		}
	});

	// Page load
	$('input.enable-source-editor').parents('.linking-note').css('display', 'inline');
	$('input.enable-source-editor').change();
});
