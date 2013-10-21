class UserSweeper < ActionController::Caching::Sweeper

	observe User

	def after_update(user)
		user.styles.each do |style|
			expire_page(:controller => 'styles', :action => 'show', :id => style.id)
		end
	end

end
