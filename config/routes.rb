Userstyles::Application.routes.draw do
  match '' => 'index#index'
  match 'categories' => 'categories#show'
  match 'categories/:id' => 'categories#show'
  resources :users
  match 'user/list' => 'users#index'
  match 'user/show/:id' => 'users#show'
  match 'user/comments/:id' => 'users#comments_redirect', :format => 'html'
  match 'user/comments_on/:id' => 'users#comments_on_redirect', :format => 'html'
  match 'user/comments/:id/:mode' => 'users#comments_redirect'
  match 'user/comments_on/:id/:mode' => 'users#comments_on_redirect'
  match 'users/:id/styles' => 'styles#by_user', :format => 'html'
  match 'users/:id/styles.:format' => 'styles#by_user'
  match 'styles/browse/:category/:search_terms.:format' => 'styles#browse', :constraints => { :search_terms => /[^\.\/]+/, :category => /[^\/\.]+/ }
  match 'styles/browse/:category/:search_terms' => 'styles#browse', :constraints => { :search_terms => /[^\.\/]+/, :category => /[^\/\.]+/ }
  match 'styles/browse/:category.:format' => 'styles#browse', :constraints => { :category => /[^\/\.]+/ }
  match 'styles/browse/:category' => 'styles#browse', :constraints => { :category => /[^\/\.]+/ }
  match 'styles/browse.:format' => 'styles#browse'
  match 'styles/browse' => 'styles#browse'
  match 'styles/browse_r/' => 'styles#browse_r'
  match 'styles/' => 'styles#browse_r'
  match 'styles/userjs/:id' => 'styles#js', :via => :post
  match 'styles/userjs/:id/:foo.user.js' => 'styles#js', :constraints => { :foo => /.*/ }
  match 'styles/js/:id/:foo.js' => 'styles#js', :constraints => { :foo => /.*/ }
  match 'styles/ieuserjs/:id/:foo.ieuser.js' => 'styles#js', :constraints => { :foo => /.*/ }
  match 'styles/operacss/:id/:foo.css' => 'styles#opera_css', :constraints => { :foo => /.*/ }
  match 'styles/iecss/:id/:foo.css' => 'styles#ie_css', :constraints => { :foo => /.*/ }
  match 'styles/chrome/:id.json' => 'styles#chrome_json'
  match 'styles/delete/:id' => 'styles#delete'
  match 'styles/admin_delete/:id' => 'styles#admin_delete'
  match 'styles/validate/:id' => 'styles#validate'
  match 'styles/stats/:id' => 'styles#stats'
  match 'styles/screenshotable' => 'styles#screenshotable'
  match 'styles/bad_stuff' => 'styles#bad_stuff'
  match 'styles/automation_page/:id' => 'styles#automation_page'
  match 'styles/lotsa_screenshots' => 'styles#lotsa_screenshots'
  match 'styles/reviewable' => 'styles#reviewable'
  match 'styles/graveyard' => 'styles#graveyard'
  match 'styles/updated' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'updated_date'
  match 'styles/updated.:format' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'updated_date'
  match 'styles/new_styles' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'created_date'
  match 'styles/new_styles.:format' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'created_date'
  match 'style/new_list' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'created_date'
  match 'style/new_list/:format' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'created_date'
  match 'style/new_feed' => 'styles#browse_r', :sort_direction => 'desc', :format => 'atom', :sort => 'created_date'
  match 'style/new_feed/rss' => 'styles#browse_r', :sort_direction => 'desc', :format => 'rss', :sort => 'created_date'
  match 'style/new_feed/atom' => 'styles#browse_r', :sort_direction => 'desc', :format => 'atom', :sort => 'created_date'
  match 'style/updated_list' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'updated_date'
  match 'style/updated_list/:format' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'updated_date'
  match 'style/updated_feed' => 'styles#browse_r', :sort_direction => 'desc', :format => 'atom', :sort => 'updated_date'
  match 'style/updated_feed/rss' => 'styles#browse_r', :sort_direction => 'desc', :format => 'rss', :sort => 'updated_date'
  match 'style/updated_feed/atom' => 'styles#browse_r', :sort_direction => 'desc', :format => 'atom', :sort => 'updated_date'
  match 'styles/:category/all' => 'styles#browse_r'
  match 'styles/site/:category' => 'styles#browse_r', :constraints => { :category => /.*/ }
  match 'styles;app' => 'styles#browse_r', :category => 'app'
  match 'styles;site' => 'styles#browse_r', :category => 'site'
  match 'styles;global' => 'styles#browse_r', :category => 'global'
  match 'style/search/:search_terms' => 'styles#browse_r', :constraints => { :search_terms => /.*/ }
  match 'styles/search/:search_terms' => 'styles#browse_r', :constraints => { :search_terms => /.*/ }
  match 'style/search_text/:search_terms' => 'styles#browse_r', :constraints => { :search_terms => /.*/ }
  match 'styles/browse/:category/:search_terms/:sort/:sort_direction/:page_o' => 'styles#browse', :constraints => { :sort_direction => /(ASC|DESC)/i, :page_o => /\d+/, :search_terms => /.+/, :category => /[^\/\.]+/ }
  match 'styles/browse/:category/:search_terms/:sort/:sort_direction/:page_o.:format' => 'styles#browse', :constraints => { :sort_direction => /(ASC|DESC)/i, :page_o => /\d+/, :search_terms => /.+/, :category => /[^\/\.]+/ }
  match 'styles/browse/all/:search_terms' => 'styles#browse_r', :constraints => { :search_terms => /.*/ }
  resources :styles
  match 'styles/:id.:format' => 'styles#show', :constraints => { :id => /[0-9]+/ }, :via => :post
  match 'styles/:id/:foo' => 'styles#show', :constraints => { :id => /[0-9]+/, :foo => /[0-9a-z-]+/ }
  match 'styles/:id/:foo.:format' => 'styles#show', :constraints => { :id => /[0-9]+/, :foo => /[0-9a-z-]+/ }
  match 'style/show/:id' => 'styles#show_redirect'
  match 'style/raw/:id' => 'styles#show', :format => 'css'
  match 'styles/raw/:id' => 'styles#show', :format => 'css'
  resources :allowed_bindings
  match 'stylish' => 'index#index'
  match 'firstrun' => 'index#firstrun'
  match 'contact' => 'index#contact'
  match '/:controller(/:action(/:id))'
  match '*path' => 'index#rescue_404'
end
