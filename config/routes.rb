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
  map.resources :users, :member => { :administration => :any }
	map.resource :session, :member => { :change_language => :any }
	
	map.general_changing_superadministration 'superadministration/general_changing', :controller => 'superadministration', :action => 'general_changing'
	map.check_color_superadministration 'superadministration/check_color', :controller => 'superadministration', :action => 'check_color'
	map.colors_changing_superadministration 'superadministration/colors_changing', :controller => 'superadministration', :action => 'colors_changing'
	map.language_switching_superadministration 'superadministration/language_switching', :controller => 'superadministration', :action => 'language_switching'
	map.translations_changing_superadministration 'superadministration/translations_changing', :controller => 'superadministration', :action => 'translations_changing'
	map.update_permissions_for_role_superadministration 'superadministration/update_permissions_for_role', :controller => 'superadministration', :action => 'update_permissions_for_role'
	map.superadministration '/superadministration/:part', :controller => 'superadministration', :action => 'superadministration'
	map.content '/content/:item_type', :controller => 'items', :action => 'index'
  
  # TODO: Publishing, Bookmarks, Admin related controllers: rights...

  map.root :controller => 'home', :action => 'index'

	#map.resources :fronts, :member => { :load_page => :any }

  map.connect '/stylesheets/:action.:format', :controller => 'stylesheets'

  # Items are CMS component types
  # => Those items may be scoped to different resources
  def items_resources(parent)  	
 		(ITEMS+['item']).each do |name|
      parent.resources name.pluralize.to_sym, :member => {
        :rate => :any,
        :add_tag => :any,
        :remove_tag => :any,
        :comment => :any
      }
    end
  end
	map.check_feed '/feed_sources/check_feed', :controller => 'feed_sources', :action => 'check_feed'
  map.what_to_do '/feed_sources/what_to_do', :controller => 'feed_sources', :action => 'what_to_do'
	#map.resources :feed_items
	
  # Items created outside any workspace are private or fully public.
  # Items may be acceded by a list that gives all items the user can consult.
  # => (his items, the public items, and items in workspaces he has permissions)
  items_resources(map)

  # Items in context of workspaces
  map.resources :workspaces, :member => { :add_new_user => :any, :subscription => :any, :unsubscription => :any, :question => :any } do |workspaces|
    workspaces.content '/:item_type', :controller => 'workspaces', :action => 'show', :conditions => { :method => :get }
    items_resources(workspaces)
  end
  
  # Project management
  #map.resources :projects  do |projects|
  #  projects.resources :meetings do |meetings|
  #    meetings.resources :objectives
  #  end
  #end
	
  #map.add_new_user '/add_new_user', :controller => 'workspaces', :action => 'add_new_user'
  map.resource :search
  map.connect '/uploads', :controller => 'uploads', :action => 'create'

  # Install the default routes as the lowest priority.
	map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end