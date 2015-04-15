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
		} else {
			var editorElement = document.querySelector(".CodeMirror");
			if (editorElement) {
				codeMirror.toTextArea();
				//var targetHeight = getComputedStyle(editorElement).height;
				//var targetWidth = getComputedStyle(editorElement).width;
				//textbox.style.height = targetHeight;
				//textbox.style.height = targetWidth;
				//editorElement.parentNode.removeChild(editorElement);
				//codeMirror.destroy();
				//codeMirror = null;
			}
		}
	});

	// Submitting form - set the textarea to the editor's value
	/*$('input.enable-source-editor').parents('form').submit(function(e) {
		var editorElement = document.getElementById("ace-editor");
		if (editorElement) {
			var textboxId = $('input.enable-source-editor').attr("data-related-editor")
			var textbox = document.getElementById(textboxId);
			textbox.value = codeMirror.getValue();
		}
	})*/

	// Page load
	$('input.enable-source-editor').parents('.linking-note').css('display', 'inline');
	$('input.enable-source-editor').change();
});
