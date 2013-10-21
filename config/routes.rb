ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "index"

	map.connect 'categories/:id', :controller => 'categories', :action => 'show'

	map.resources :users
	map.connect 'user/list', :controller => 'users', :action => 'index'
	map.connect 'user/show/:id', :controller => 'users', :action => 'show'
	map.connect 'user/comments/:id', :controller => 'users', :action => 'comments_redirect', :format => "html"
	map.connect 'user/comments_on/:id', :controller => 'users', :action => 'comments_on_redirect', :format => "html"
	map.connect 'user/comments/:id/:mode', :controller => 'users', :action => 'comments_redirect'
	map.connect 'user/comments_on/:id/:mode', :controller => 'users', :action => 'comments_on_redirect'
	map.connect 'users/:id/styles', :controller => 'styles', :action => 'by_user', :format => "html"
	map.connect 'users/:id/styles.:format', :controller => 'styles', :action => 'by_user'

	map.connect 'styles/browse/:category/:search_terms.:format', :controller => 'styles', :action => 'browse', :requirements => {:search_terms => /[^\.\/]+/, :category => /[^\/\.]+/}
	map.connect 'styles/browse/:category/:search_terms', :controller => 'styles', :action => 'browse', :requirements => {:search_terms => /[^\.\/]+/, :category => /[^\/\.]+/}
	map.connect 'styles/browse/:category.:format', :controller => 'styles', :action => 'browse', :requirements => {:category => /[^\/\.]+/}
	map.connect 'styles/browse/:category', :controller => 'styles', :action => 'browse', :requirements => {:category => /[^\/\.]+/}
	map.connect 'styles/browse.:format', :controller => 'styles', :action => 'browse'
	map.connect 'styles/browse', :controller => 'styles', :action => 'browse'
	map.connect 'styles/browse_r/', :controller => 'styles', :action => 'browse_r'
	map.connect 'styles/', :controller => 'styles', :action => 'browse_r'

	# used for POSTs to make GM ignore
	map.connect 'styles/userjs/:id', :controller => 'styles', :action => 'js', :conditions => { :method => :post }
	# used for GETs to make GM trigger
	map.connect 'styles/userjs/:id/:foo.user.js', :controller => 'styles', :action => 'js', :requirements => { :foo => /.*/ }
	map.connect 'styles/js/:id/:foo.js', :controller => 'styles', :action => 'js', :requirements => { :foo => /.*/ }
	map.connect 'styles/ieuserjs/:id/:foo.ieuser.js', :controller => 'styles', :action => 'js', :requirements => { :foo => /.*/ }
	map.connect 'styles/operacss/:id/:foo.css', :controller => 'styles', :action => 'opera_css', :requirements => { :foo => /.*/ }
	map.connect 'styles/iecss/:id/:foo.css', :controller => 'styles', :action => 'ie_css', :requirements => { :foo => /.*/ }
	map.connect 'styles/chrome/:id.json', :controller => 'styles', :action => 'chrome_json'

	map.connect 'styles/delete/:id', :controller => 'styles', :action => 'delete'
	map.connect 'styles/admin_delete/:id', :controller => 'styles', :action => 'admin_delete'
	map.connect 'styles/validate/:id', :controller => 'styles', :action => 'validate'
	map.connect 'styles/stats/:id', :controller => 'styles', :action => 'stats'
	map.connect 'styles/screenshotable', :controller => 'styles', :action => 'screenshotable'
	map.connect 'styles/bad_stuff', :controller => 'styles', :action => 'bad_stuff'
	map.connect 'styles/automation_page/:id', :controller => 'styles', :action => 'automation_page'
	map.connect 'styles/lotsa_screenshots', :controller => 'styles', :action => 'lotsa_screenshots'
	map.connect 'styles/reviewable', :controller => 'styles', :action => 'reviewable'
	map.connect 'styles/graveyard', :controller => 'styles', :action => 'graveyard'

	#legacy style listing urls
	map.connect 'styles/updated', :controller => 'styles', :action => 'browse_r', :sort => 'updated_date', :sort_direction => 'desc'
	map.connect 'styles/updated.:format', :controller => 'styles', :action => 'browse_r', :sort => 'updated_date', :sort_direction => 'desc'
	map.connect 'styles/new_styles', :controller => 'styles', :action => 'browse_r', :sort => 'created_date', :sort_direction => 'desc'
	map.connect 'styles/new_styles.:format', :controller => 'styles', :action => 'browse_r', :sort => 'created_date', :sort_direction => 'desc'
	map.connect 'style/new_list', :controller => 'styles', :action => 'browse_r', :sort => 'created_date', :sort_direction => 'desc'
	map.connect 'style/new_list/:format', :controller => 'styles', :action => 'browse_r', :sort => 'created_date', :sort_direction => 'desc'
	map.connect 'style/new_feed', :controller => 'styles', :action => 'browse_r', :sort => 'created_date', :sort_direction => 'desc', :format => 'atom'
	map.connect 'style/new_feed/rss', :controller => 'styles', :action => 'browse_r', :sort => 'created_date', :sort_direction => 'desc', :format => 'rss'
	map.connect 'style/new_feed/atom', :controller => 'styles', :action => 'browse_r', :sort => 'created_date', :sort_direction => 'desc', :format => 'atom'
	map.connect 'style/updated_list', :controller => 'styles', :action => 'browse_r', :sort => 'updated_date', :sort_direction => 'desc'
	map.connect 'style/updated_list/:format', :controller => 'styles', :action => 'browse_r', :sort => 'updated_date', :sort_direction => 'desc'
	map.connect 'style/updated_feed', :controller => 'styles', :action => 'browse_r', :sort => 'updated_date', :sort_direction => 'desc', :format => 'atom'
	map.connect 'style/updated_feed/rss', :controller => 'styles', :action => 'browse_r', :sort => 'updated_date', :sort_direction => 'desc', :format => 'rss'
	map.connect 'style/updated_feed/atom', :controller => 'styles', :action => 'browse_r', :sort => 'updated_date', :sort_direction => 'desc', :format => 'atom'
	map.connect 'styles/:category/all', :controller => 'styles', :action => 'browse_r'
	map.connect 'styles/site/:category', :controller => 'styles', :action => 'browse_r', :requirements => {:category => /.*/}
	map.connect 'styles;app', :controller => 'styles', :action => 'browse_r', :category => 'app'
	map.connect 'styles;site', :controller => 'styles', :action => 'browse_r', :category => 'site'
	map.connect 'styles;global', :controller => 'styles', :action => 'browse_r', :category => 'global'
	map.connect 'style/search/:search_terms', :controller => 'styles', :action => 'browse_r', :requirements => { :search_terms => /.*/ }
	map.connect 'styles/search/:search_terms', :controller => 'styles', :action => 'browse_r', :requirements => { :search_terms => /.*/ }
	map.connect 'style/search_text/:search_terms', :controller => 'styles', :action => 'browse_r', :requirements => { :search_terms => /.*/ }
	map.connect 'styles/browse/:category/:search_terms/:sort/:sort_direction/:page_o', :controller => 'styles', :action => 'browse', :requirements => {:sort_direction => /(ASC|DESC)/i, :page_o => /\d+/, :search_terms => /.+/, :category => /[^\/\.]+/}
	map.connect 'styles/browse/:category/:search_terms/:sort/:sort_direction/:page_o.:format', :controller => 'styles', :action => 'browse', :requirements => {:sort_direction => /(ASC|DESC)/i, :page_o => /\d+/, :search_terms => /.+/, :category => /[^\/\.]+/}
	map.connect 'styles/browse/all/:search_terms', :controller => 'styles', :action => 'browse_r', :requirements => { :search_terms => /.*/ }

	map.resources :styles

	# support getting code with post
	map.connect 'styles/:id.:format', :controller => 'styles', :action => 'show', :requirements => { :id => /[0-9]+/ }, :conditions => { :method => :post }

	map.connect 'styles/:id/:foo', :controller => 'styles', :action => 'show', :requirements => { :foo => /[0-9a-z-]+/, :id => /[0-9]+/ }
	map.connect 'styles/:id/:foo.:format', :controller => 'styles', :action => 'show', :requirements => { :foo => /[0-9a-z-]+/, :id => /[0-9]+/ }
	map.connect 'style/show/:id', :controller => 'styles', :action => 'show_redirect'
	map.connect 'style/raw/:id', :controller => 'styles', :action => 'show', :format => 'css'
	map.connect 'styles/raw/:id', :controller => 'styles', :action => 'show', :format => 'css'

	map.resources :allowed_bindings

	map.connect 'stylish', :controller => 'index', :action => 'index'
	map.connect 'firstrun', :controller => 'index', :action => 'firstrun'
	map.connect 'contact', :controller => 'index', :action => 'contact'

	# Install the default route as the lowest priority.
	map.connect ':controller/:action/:id'
	map.connect ':controller/:action/:id.:format'

	map.connect '*path', :controller => 'index', :action => 'rescue_404'
end
