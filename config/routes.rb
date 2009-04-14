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
  map.resources :users, :member => { :administration => :any }, :collection => { :autocomplete_on => :any }
	map.resource :session, :member => { :change_language => :any }
	map.resources :people, :collection => {:export_people=>:any, :import_people => :any,:ajax_index => :get }
  
	map.general_changing_superadministration 'superadministration/general_changing', :controller => 'superadministration', :action => 'general_changing'
	map.check_color_superadministration 'superadministration/check_color', :controller => 'superadministration', :action => 'check_color'
	map.colors_changing_superadministration 'superadministration/colors_changing', :controller => 'superadministration', :action => 'colors_changing'
	map.language_switching_superadministration 'superadministration/language_switching', :controller => 'superadministration', :action => 'language_switching'
	map.translations_changing_superadministration 'superadministration/translations_changing', :controller => 'superadministration', :action => 'translations_changing'
	map.translations_new_superadministration 'superadministration/translations_new', :controller => 'superadministration', :action => 'translations_new'
	map.superadministration '/superadministration/:part', :controller => 'superadministration', :action => 'superadministration'
	
	map.resources :home, :only => [:index], :collection => { :autocomplete_on => :any, :autocomplete_on_user => :any }

  map.resources :roles
  map.resources :permissions
	map.resources :comments, :only => [:index, :edit, :update], :member => { :change_state => :any }
  
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
        :add_comment => :any
      }
    end
  end
	map.check_feed '/feed_sources/check_feed', :controller => 'feed_sources', :action => 'check_feed'
  map.what_to_do '/feed_sources/what_to_do', :controller => 'feed_sources', :action => 'what_to_do'
  map.send_newsletter '/send_newsletter', :controller => 'newsletters', :action => 'send_newsletter'
	#map.resources :feed_items
	map.content '/content/:item_type', :controller => 'items', :action => 'index'
  map.ajax_content '/ajax_content/:item_type', :controller => 'items', :action => 'ajax_index'
  map.display_content_list '/display_content_list/:item_type', :controller => 'items', :action => 'display_item_in_pop_up'
	
  # Items created outside any workspace are private or fully public.
  # Items may be acceded by a list that gives all items the user can consult.
  # => (his items, the public items, and items in workspaces he has permissions)
  items_resources(map)

  # Items in context of workspaces
  map.resources :workspaces, :member => { :add_new_user => :any, :subscription => :any, :unsubscription => :any, :question => :any } do |workspaces|
    workspaces.content '/:item_type', :controller => 'workspaces', :action => 'show', :conditions => { :method => :get }
    items_resources(workspaces)
  end
  map.workspace_ajax_content 'workspace_ajax_content', :controller => 'workspaces', :action => 'ajax_show', :conditions => { :method => :get }
  # Project management
  #map.resources :projects  do |projects|
  #  projects.resources :meetings do |meetings|
  #    meetings.resources :objectives
  #  end
  #end
	
  #map.add_new_user '/add_new_user', :controller => 'workspaces', :action => 'add_new_user'
  map.resources :searches, :collection => { :print_advanced => :any }
  map.connect '/fckuploads', :controller => 'fck_uploads', :action => 'create'

  # Install the default routes as the lowest priority.
	map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end