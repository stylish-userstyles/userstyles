class StyleSweeper < ActionController::Caching::Sweeper

	observe Style

	def after_create(style)
		expire_page(:controller => 'styles', :action => 'new_list')
		expire_page(:controller => 'styles', :action => 'new_list', :mode => 'html')
		expire_page(:controller => 'styles', :action => 'new_list', :mode => 'rss')
		expire_page(:controller => 'styles', :action => 'new_list', :mode => 'atom')
		style.write_md5
	end

#	def before_update(style)
#		expire_page("/styles/#{style.id}/#{style.url_snippet}")
#	end

	def after_update(style)
		expire_page(:controller => 'styles', :action => 'updated_list')
		expire_page(:controller => 'styles', :action => 'updated_list', :mode => 'html')
		expire_page(:controller => 'styles', :action => 'updated_list', :mode => 'rss')
		expire_page(:controller => 'styles', :action => 'updated_list', :mode => 'atom')
		#expire_page(:controller => 'styles', :action => 'show', :id => style.id)
		#this doesn't route right, so just put its url in
		#expire_page("/styles/#{style.id}.css")
		expire_fragment(:controller => 'styles', :action => 'show', :id => style.id, :format=> 'css')
		#expire_page("/styles/#{style.id}.md5")
		#expire_page("/styles/#{style.id}/#{style.url_snippet}")
		delete_all_for_id(style.id)
		style.write_md5
	end

	private

	def delete_all_for_id(id)
		FileUtils.rm_rf Dir.glob("#{Rails.root}/public/styles/#{id}.*"), :secure => true
		FileUtils.rm_rf "#{Rails.root}/public/styles/#{id}/", :secure => true
	end

end
