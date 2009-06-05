# The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.

ActionController::Routing::Routes.draw do |map|

  # Generated by Restful Authentification
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  #map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
	map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  #map.change_password '/change_password', :controller => 'users', :action => 'change_password'
  map.reset_password '/reset_password/:password_reset_code', :controller => 'users', :action => 'reset_password'
  map.resources :users, :member => { :administration => :any }, :collection => { :autocomplete_on => :any, :validate => :any }
	map.resource :session, :member => { :change_language => :any }
	map.resources :people, :collection => {:export_people=>:any, :import_people => :any,:ajax_index => :get,:get_empty_csv => :get, :validate => :any ,:filter => :get}

  # Routes Related to SuperAdministrator
	map.general_changing_superadministration 'superadministration/general_changing', :controller => 'superadministration', :action => 'general_changing'
	map.check_color_superadministration 'superadministration/check_color', :controller => 'superadministration', :action => 'check_color'
	map.colors_changing_superadministration 'superadministration/colors_changing', :controller => 'superadministration', :action => 'colors_changing'
	map.language_switching_superadministration 'superadministration/language_switching', :controller => 'superadministration', :action => 'language_switching'
	map.translations_changing_superadministration 'superadministration/translations_changing', :controller => 'superadministration', :action => 'translations_changing'
	map.translations_new_superadministration 'superadministration/translations_new', :controller => 'superadministration', :action => 'translations_new'
	map.superadministration '/superadministration/:part', :controller => 'superadministration', :action => 'superadministration'

  # Route for HomePage
	map.resources :home, :only => [:index], :collection => { :autocomplete_on => :any }

  # Routes for Roles and Permissions in BA
  map.resources :roles
  map.resources :permissions

  # Routes for Comments
	map.resources :comments, :only => [:index, :edit, :update], :member => { :change_state => :any }
  
  # TODO: Publishing, Bookmarks, Admin related controllers: rights...
  map.root :controller => 'home', :action => 'index'

	#map.resources :fronts, :member => { :load_page => :any }
  # Route for generating Dynamic CSS
  map.connect '/stylesheets/:action.:format', :controller => 'stylesheets'

  # Items are CMS component types
  # => Those items may be scoped to different resources
  def items_resources(parent)  	
 		(ITEMS+['item']).each do |name|
      parent.resources name.pluralize.to_sym, :member => {
        :rate => :any,
        :add_tag => :any,
        :remove_tag => :any,
        :add_comment => :any
      }, :collection => {:validate => :any}
    end
    # Displaying Items
    parent.content '/content/:item_type', :controller => 'items', :action => 'index'
    # Ajax Pagination on Content
    parent.ajax_content '/ajax_content/:item_type', :controller => 'items', :action => 'ajax_index'
  end

  # Feed related routes
	map.check_feed '/feed_sources/check_feed', :controller => 'feed_sources', :action => 'check_feed'
  map.what_to_do '/feed_sources/what_to_do', :controller => 'feed_sources', :action => 'what_to_do'

  # Newsletter related routes
  map.send_newsletter '/send_newsletter', :controller => 'newsletters', :action => 'send_newsletter'
  map.unsubscribe_for_newsletter '/unsubscribe_for_newsletter', :controller => 'newsletters', :action => 'unsubscribe'
	#map.resources :feed_items
	#map.content '/content/:item_type', :controller => 'items', :action => 'index'
  #map.ajax_content '/ajax_content/:item_type', :controller => 'items', :action => 'ajax_index'

  # Displaying items in POP UP for fck editor
  map.display_content_list '/display_content_list/:selected_item', :controller => 'items', :action => 'display_item_in_pop_up'
	
  # Items created outside any workspace are private or fully public.
  # Items may be acceded by a list that gives all items the user can consult.
  # => (his items, the public items, and items in workspaces he has permissions)
  items_resources(map)
  map.connect '/workspaces/management', :controller => 'workspaces', :action => 'management'
  
  # Items in context of workspaces
  map.resources :workspaces, :member => { :add_new_user => :any, :subscription => :any, :unsubscription => :any, :question => :any }, :collection => {:validate => :any} do |workspaces|
    #workspaces.content '/content/:item_type', :controller => 'workspaces', :action => 'show', :conditions => { :method => :get }
    items_resources(workspaces)
  end
  #map.workspace_ajax_content 'workspace_ajax_content', :controller => 'workspaces', :action => 'ajax_content', :conditions => { :method => :get }
  # Project management
  #map.resources :projects  do |projects|
  #  projects.resources :meetings do |meetings|
  #    meetings.resources :objectives
  #  end
  #end
	
  #map.add_new_user '/add_new_user', :controller => 'workspaces', :action => 'add_new_user'
  # Search related routes
  map.resources :searches, :collection => { :print_advanced => :any }
 
  # Route to export Group Members
  map.export_group '/export_group/:id', :controller => 'groups', :action => 'export_group'
  map.get_audio_progress '/get_audio_progress', :controller => 'audios', :action => 'get_audio_progress'
  map.get_video_progress '/get_video_progress', :controller => 'videos', :action => 'get_video_progress'
  # FCKUPLOAD route for uploads throught fckeditor
  map.connect '/fckuploads', :controller => 'fck_uploads', :action => 'create'
  # Install the default routes as the lowest priority.
	#map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end