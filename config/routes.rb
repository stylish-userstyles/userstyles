Userstyles::Application.routes.draw do
  get '' => 'index#index'
  get 'categories' => 'categories#show'
  get 'categories/:id' => 'categories#show'

  get '/auth/:provider/callback', to: 'login#omniauth_callback', :as => 'omniauth_callback'
  # BrowserID POSTs
  post '/auth/:provider/callback', to: 'login#omniauth_callback'
  get '/auth/failure', to: 'login#omniauth_failure'
  get '/auth/failure2', to: 'login#omniauth_failure'

  resources :users
  get 'user/list' => 'users#index'
  get 'user/show/:id' => 'users#show'
  get 'user/comments/:id' => 'users#comments_redirect', :format => 'html'
  get 'user/comments_on/:id' => 'users#comments_on_redirect', :format => 'html'
  get 'user/comments/:id/:mode' => 'users#comments_redirect'
  get 'user/comments_on/:id/:mode' => 'users#comments_on_redirect'
  get 'users/:id/styles.:format', to: redirect('/users/%{id}.%{format}')
  get 'users/:id/styles', to: redirect('/users/%{id}')

  get 'styles/test' => 'styles#test'
  get 'styles/browse/all/:search_terms' => 'styles#browse_r', :constraints => { :search_terms => /.*/ }
  get 'styles/browse/:category/:search_terms.:format' => 'styles#browse', :constraints => { :search_terms => /[^\.\/]+/, :category => /[^\/\.]+/ }
  get 'styles/browse/:category/:search_terms' => 'styles#browse', :constraints => { :search_terms => /[^\.\/]+/, :category => /[^\/\.]+/ }
  get 'styles/browse/:category.:format' => 'styles#browse', :constraints => { :category => /[^\/\.]+/ }
  get 'styles/browse/:category' => 'styles#browse', :constraints => { :category => /[^\/\.]+/ }
  get 'styles/browse.:format' => 'styles#browse'
  get 'styles/browse' => 'styles#browse'
  get 'styles/browse_r/' => 'styles#browse_r'
  get 'styles/' => 'styles#browse_r'
  post 'styles/userjs/:id' => 'styles#js'
  get 'styles/userjs/:id/:foo.:format' => 'styles#js', :constraints => { :foo => /.*/, :format => /(user|meta)\.js/ }
  get 'styles/js/:id/:foo.js' => 'styles#js', :constraints => { :foo => /.*/ }
  get 'styles/ieuserjs/:id/:foo.ieuser.js' => 'styles#js', :constraints => { :foo => /.*/ }
  get 'styles/operacss/:id/:foo.css' => 'styles#opera_css', :constraints => { :foo => /.*/ }
  get 'styles/iecss/:id/:foo.css' => 'styles#ie_css', :constraints => { :foo => /.*/ }
  match 'styles/chrome/:id.json' => 'styles#chrome_json', via: [:get, :post]
  get 'styles/delete/:id' => 'styles#delete'
  get 'styles/admin_delete/:id' => 'styles#admin_delete'
  get 'styles/validate/:id' => 'styles#validate'
  get 'styles/stats/:id' => 'styles#stats'
  get 'styles/screenshotable' => 'styles#screenshotable'
  get 'styles/bad_stuff' => 'styles#bad_stuff'
  get 'styles/automation_page/:id' => 'styles#automation_page'
  get 'styles/lotsa_screenshots' => 'styles#lotsa_screenshots'
  get 'styles/reviewable' => 'styles#reviewable'
  get 'styles/graveyard' => 'styles#graveyard'
  get 'styles/updated' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'updated_date'
  get 'styles/updated.:format' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'updated_date'
  get 'styles/new_styles' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'created_date'
  get 'styles/new_styles.:format' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'created_date'
  get 'style/new_list' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'created_date'
  get 'style/new_list/:format' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'created_date'
  get 'style/new_feed' => 'styles#browse_r', :sort_direction => 'desc', :format => 'atom', :sort => 'created_date'
  get 'style/new_feed/rss' => 'styles#browse_r', :sort_direction => 'desc', :format => 'rss', :sort => 'created_date'
  get 'style/new_feed/atom' => 'styles#browse_r', :sort_direction => 'desc', :format => 'atom', :sort => 'created_date'
  get 'style/updated_list' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'updated_date'
  get 'style/updated_list/:format' => 'styles#browse_r', :sort_direction => 'desc', :sort => 'updated_date'
  get 'style/updated_feed' => 'styles#browse_r', :sort_direction => 'desc', :format => 'atom', :sort => 'updated_date'
  get 'style/updated_feed/rss' => 'styles#browse_r', :sort_direction => 'desc', :format => 'rss', :sort => 'updated_date'
  get 'style/updated_feed/atom' => 'styles#browse_r', :sort_direction => 'desc', :format => 'atom', :sort => 'updated_date'
  get 'styles/:category/all' => 'styles#browse_r'
  get 'styles/site/:category' => 'styles#browse_r', :constraints => { :category => /.*/ }
  get 'styles;app' => 'styles#browse_r', :category => 'app'
  get 'styles;site' => 'styles#browse_r', :category => 'site'
  get 'styles;global' => 'styles#browse_r', :category => 'global'
  get 'style/search/:search_terms' => 'styles#browse_r', :constraints => { :search_terms => /.*/ }
  get 'styles/search/:search_terms' => 'styles#browse_r', :constraints => { :search_terms => /.*/ }
  get 'style/search_text/:search_terms' => 'styles#browse_r', :constraints => { :search_terms => /.*/ }
  get 'styles/browse/:category/:search_terms/:sort/:sort_direction/:page_o' => 'styles#browse', :constraints => { :sort_direction => /(ASC|DESC)/i, :page_o => /\d+/, :search_terms => /.+/, :category => /[^\/\.]+/ }
  get 'styles/browse/:category/:search_terms/:sort/:sort_direction/:page_o.:format' => 'styles#browse', :constraints => { :sort_direction => /(ASC|DESC)/i, :page_o => /\d+/, :search_terms => /.+/, :category => /[^\/\.]+/ }
  resources :styles
  post 'styles/:id.:format' => 'styles#show', :constraints => { :id => /[0-9]+/ }
  get 'styles/:id/:slug' => 'styles#show', :constraints => { :id => /[0-9]+/, :slug => /[^\?\/\.]+/ }
  get 'styles/:id/:slug.:format' => 'styles#show', :constraints => { :id => /[0-9]+/, :slug => /[^\?\/\.]+/ }
  get 'style/show/:id' => 'styles#show_redirect'
  get 'style/raw/:id' => 'styles#show', :format => 'css'
  get 'styles/raw/:id' => 'styles#show', :format => 'css'
  post 'report' => 'styles#report'

  get 'stylish' => 'index#index'
  get 'firstrun' => 'index#firstrun'
  get 'contact' => 'index#contact'
  get 'admin_debug' => 'index#admin_debug'
  get 'dberror', to: redirect('/help/db_chrome')
  get 'terms-of-use' => 'misc#terms'
  get 'login/policy' => 'login#policy'
  get 'copyright-notice' => 'misc#policy'

  match '*path' => 'index#rescue_404', via: [:get, :post]
end
