class StyleGeneratorController < ApplicationController

	layout "standard_layout"

	public

		def orkut
			@page_title = 'Orkut Background Style Generator'
		end

		def orkut_generate
			@page_title = 'Orkut Background Style Generator'
			if !is_image(params[:image])
				@error = 'Images must be PNG, GIF, or JPG.'
				render :action => 'orkut'
				return
			end
			@header_include = "<link rel='stylish-code' href='#stylish-code'/>\n<link rel='stylish-description' href='#stylish-description'/>".html_safe
			@description = 'Orkut Custom Background'
			if params[:type] == 'dark'
				@code = orkut_template_dark(to_base_64(params[:image]))
			else
				@code = orkut_template_light(to_base_64(params[:image]))
			end
			render :action => 'result'
		end

	private

		def is_image(upload)
			return false if upload.nil? or upload.content_type.nil?
			type = upload.content_type.strip
			return !['image/png', 'image/gif', 'image/jpg', 'image/jpeg'].index(type).nil?
		end

		def to_base_64(image)
			return 'data:' + image.content_type.strip + ';base64,' + CGI::escape(Base64.encode64(image.read).gsub(/\s/, ''))
		end

		def orkut_template_dark(image)
				string = <<-END_OF_STRING
/* Orkut background style - http://userstyles.org/style_generator/orkut */
@namespace url(http://www.w3.org/1999/xhtml);

@-moz-document domain(orkut.com), domain(orkut.com.br) {
	body {
		background-image: url("#{image}") !important;
	}

	* {
		background: transparent !important;
		color: white !important;
	}

	iframe[name="google_ads_frame"] {
		display: none !important;
	}
}
				END_OF_STRING
		end

		def orkut_template_light(image)
				string = <<-END_OF_STRING
/* Orkut background style - http://userstyles.org/style_generator/orkut */
@namespace url(http://www.w3.org/1999/xhtml);

@-moz-document domain(orkut.com), domain(orkut.com.br) {
	body {
		background-image: url("#{image}") !important;
	}

	* {
		background: transparent !important;
	}

	iframe[name="google_ads_frame"] {
		display: none !important;
	}
}
				END_OF_STRING
		end
	
end
