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

  # Blank Specific Routes
  # Routes Related to SuperAdministrator
	map.namespace :superadmin do |sa|
		sa.connect '', :controller => 'superadmin/administration', :action => 'show'
		sa.resources :general_settings, :only => [:index, :update], :collection => { :editing => :get, :updating => :put }
		sa.resources :audits, :only => [:index]
		sa.resources :user_interfaces, :only => [:index, :update], :collection => { :editing => :get, :updating => :put, :check_color => :get, :colors_changing => :get }
		sa.resources :tasks, :only => [:index], :collection => { :run_task => :get }
		sa.resources :translations, :only => [:index, :update], :collection => { :updating => :put, :context_switching => :get, :translation_new => :any , :new_project => :any, :new_language => :any, :section_switching => :any }
    sa.resources :mailer_settings, :only => [:index, :update], :collection => { :updating => :put }
    # Routes for Roles and Permissions in BA
    sa.resources :roles, :collection => {:validate => :post}
    sa.resources :permissions, :collection => {:validate => :post}
    sa.resources :google_analytics, :only => [:index], :collection => {:updating => :put}
	end

  map.namespace :admin do |admin|
    # Generated by Restful Authentification
    admin.logout '/logout', :controller => 'sessions', :action => 'destroy'
    admin.login '/login', :controller => 'sessions', :action => 'new'
    admin.signup '/signup', :controller => 'users', :action => 'new'
    admin.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
    admin.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
    admin.reset_password '/reset_password/:password_reset_code', :controller => 'users', :action => 'reset_password'
    admin.resources :users, :member => { :locking => :any, :resend_activation_mail_or_activate_manually => :post },
      :collection => {:autocomplete_on => :any, :validate => :any } do |user|
      user.resources :notifications, :only => [:index, :create]
    end

    # Sessions for managing user sessions
    admin.resource :session


    # Routes for People
    admin.resources :people, :collection => {:export_people => :any, :import_people => :any, :get_empty_csv => :get, :validate => :any ,:filter => :get }

    # Route for HomePage
    admin.resources :home, :only => [:index], :collection => { :autocomplete_on => :any }

    # Routes for Comments
    admin.resources :comments, :only => [:index, :edit, :update, :destroy], :member => { :change_state => :any, :add_reply => :any}, :collection => {:validate => :post}
    # Routes for ratings
    admin.resources :ratings, :only => [:index]
    # Route for HomePage
    admin.root :controller => 'home', :action => 'index'

    # Items are CMS component types
    # Those items may be scoped to different resources
    def items_resources(parent)
      (ITEMS).each do |name|
        member_to_set = {
          :rate => :any,
          :add_comment => :any,
          :redirect_to_content => :any
        }
        member_to_set.merge!({:results => :get}) if name == 'result_set'
        member_to_set.merge!({:remove_file => :any}) if name =='article'
        member_to_set.merge!({:get_video_progress => :any}) if name =='video'
        member_to_set.merge!({:get_audio_progress => :any}) if name =='audio'
        member_to_set.merge!({:send_to_a_group => :any}) if name =='newsletter'
        member_to_set.merge!({:export_to_csv => :any}) if name =='group'
        member_to_set.merge!({:download => :any}) if ['audio', 'video', 'cms_file', 'image'].include?(name)
        collection_to_set = {
          :validate => :post
        }
        collection_to_set.merge!({:filtering_contacts => :get}) if name=='group'
        parent.resources name.pluralize.to_sym, :member => member_to_set, :collection => collection_to_set
      end
      parent.content '/content/:item_type', :controller => 'content', :action => 'index'
      parent.ajax_content '/ajax_content/:item_type', :controller => 'content', :action => 'ajax_index'
      parent.content_popup '/content_for_popup/:selected_item', :controller => 'content', :action => 'display_item_in_pop_up'
      #TODO delete pop_up, no more used.
    end

    # Newsletter related routes
    admin.unsubscribe_for_newsletter 'admin/unsubscribe_for_newsletter', :controller => 'workspace_contacts', :action => 'unsubscribe'

    # FCKTools route for utilities methods for FCK editor
    admin.connect '/ck_uploads/:item_type', :controller => 'ck_tools', :action => 'upload_from_ck'
    admin.connect '/ck_config', :controller => 'ck_tools', :action => 'config_file'
    admin.connect '/ck_display/tabs/:tab_name', :controller => 'ck_tools', :action => 'tabs'
    admin.connect '/ck_insert/gallery', :controller => 'ck_tools', :action => 'insert_gallery'
    admin.connect '/ajax_item_save/:item_type/:id', :controller => 'ck_tools', :action => "ajax_item_save" 
    admin.connect '/ajax_container_save/:container/:id', :controller => 'ck_tools', :action => "ajax_container_save"
    
    admin.connect '/analytics_datas', :controller => 'home', :action => 'analytics_datas'

    # Items created outside any workspace are private or fully public.
    # Items may be acceded by a list that gives all items the user can consult.
    # => (his items, the public items, and items in workspaces he has permissions)
    items_resources(admin)

    CONTAINERS.each do |container|
      admin.resources "#{container.pluralize}".to_sym, :member => { :add_new_user => :any }, :collection => {:validate => :post, :delete_asset => :any} do |con|
        con.resources :subscriptions, :only => [:create, :destroy], :collection => { :request => :any }
        items_resources(con)
        if container == 'workspace'
          con.resources :people, :collection => { :export_people => :any, :import_people => :any, :get_empty_csv => :get, :validate => :post ,:filter => :get }
          con.resources :workspace_contacts, :as => 'contacts', :except => :all, :collection => { :select => [:post, :get], :list => [:post, :get], :subscribe => :get}
        end
        if container == 'website'
          con.resources :analytics, :only => [:index]
          con.resources :menus
        end
        con.resources :zip_uploads
      end
    end

    # Search related routes
    admin.resources :searches, :collection => { :print_advanced => :any, :validate => :post }

  # Catch Errors and show custom message, avoid SWW
    admin.error '/admin/error/:status' , :controller => 'home', :action => 'error'
    
  end
  #################################################################################
  
  map.resources :users, :only => [:new, :create], :collection => {:validate => :post}
  # Add Project Specific Routes here!
  # Website Home
  map.resources :contacts, :only => [:new, :create]
  map.root :controller => "websites", :action => 'index'
  map.connect '/site/:site_title', :controller => 'websites', :action => 'index'
  map.connect '/site/:site_title/:title_sanitized', :controller => 'websites', :action => 'index'
  map.connect '/:title_sanitized', :controller =>'websites', :action => 'index'
  map.connect '/:item_type/:id', :controller =>'websites', :action => 'show'
  map.resources :websites, :only => [:index, :update]
  map.error '/error/:status', :controller => 'websites', :action => 'error'
  #map.create_front_folders '/create_front_folders', :controller => 'fronts', :action => 'create_front_folders'
  #map.export_contacts '/export_contacts/:website_id', :controller =>'websites', :action => 'export_contacts'
  #map.connect '/web/form_submit', :controller => 'websites', :action => 'contact_submit'
  #map.connect '/web', :controller =>'websites', :action => 'load_site'
  #map.connect '/actu/all', :controller =>'news_reports', :action => 'list'
  #map.connect '/actu/:title_sanitized', :controller =>'websites', :action => 'load_news'
  #map.connect '*global_error_page', :controller=>'websites', :action=>'load_site'
  
end