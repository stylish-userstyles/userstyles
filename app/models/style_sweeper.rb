class StyleSweeper < ActionController::Caching::Sweeper

	observe Style

	def after_create(style)
		style.write_md5
	end

	def after_update(style)
		Rails.cache.delete "styles/show/#{style.id}"
		style.write_md5
	end

end
