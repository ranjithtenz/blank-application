# This module is defining the different methods and actions required by an Object controller to acts like an Item.
# It is so defining the mixin method that will include all these required methods and actions inside this Object controller.
#
module ActsAsItem
  module ControllerMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      # Mixin adding initialisation and definition of an item controller
      #
      # This method initialize a controller by mixin of the specified methods,
			# and it can take a block in parameter to add others MakeResourceful plugin filters.
      #
      # Usage :
      # app/controllers/articles_controller.rb
      #
      #     class ArticlesController < ApplicationController
      #      acts_as_item do
      #         before :create do
			#           ....
			#         end
      #       end
      #     end
      def acts_as_item &block
				# Inclusion of the instance methods inside the mixin method
        include ActsAsItem::ControllerMethods::InstanceMethods
				# Declaration of the AjaxValidation plugin
				acts_as_ajax_validation

				acts_as_authorizable({
					'new' => 'new',
					'create' => 'new',
					'edit' => 'edit',
					'update' => 'edit',
					'show' => 'show',
					'rate' => 'rate',
					'add_comment' => 'comment',
					'destroy' => 'destroy',
					'validate' => 'edit'
				}, [:redirect_to_content])
				# Declaration of the ActAsCommentable plugin
				acts_as_commentable
				# Declaration of the ActsAsKeywordable plugin
				acts_as_keywordable

				# Filter allowing to update the Xapian index with the delta brought by that object (Superfast solution, but performance less)
				after_filter :only => [:create, :update, :destroy] do
					Thread.new do
						system("rake xapian:update_index RAILS_ENV=#{RAILS_ENV}")
					end
				end

				# Filter checking the permission depending of the action and the controller given with request params
#				before_filter :permission_checking, :only => [:new, :create, :edit, :update, :show, :destroy]
				# Filter skipped in case of the 'redirect_to_content action'
#				skip_before_filter :is_logged?, :only => [:redirect_to_content]

				# MakeResourceful definitions
        make_resourceful do
					# Declaration of all the CRUD methods : new,create,edit,update,show,index
          actions :all
					# 
          belongs_to :workspace

					# Inclusion of the block if a block is found
          self.instance_eval &block if block_given?

					# Filter setting the Flash message linked to that action
          after :create do
            flash[:notice] = @current_object.class.label+' '+I18n.t('item.new.flash_notice')
          end
					# Filter setting the Flash message linked to that action
          after :create_fails do
            flash.now[:error] = @current_object.class.label+' '+I18n.t('item.new.flash_error')
          end
					# Filter setting the Flash message linked to that action, and removing the item information (used by FCKeditor)
          after :update do
            session[:fck_item_id] = nil
            session[:fck_item_type] = nil
            flash[:notice] = @current_object.class.label+' '+I18n.t('item.edit.flash_notice')
          end
          # Filter setting the Flash message linked to that action
          after :update_fails do
            flash.now[:error] = @current_object.class.label+' '+I18n.t('item.edit.flash_error')
          end
					# Filter updating the 'viewed_number' attribute of the item
          before :show do
						@current_object.viewed_number = @current_object.viewed_number.to_i + 1
						@current_object.save
          end
					# Filter saving in the session the item information (used by FCKeditor)
          before :edit, :update do
						session[:fck_item_id] = @current_object.id
            session[:fck_item_type] = @current_object.class.to_s
          end
          # Makes `current_user` as author for the current_object
          before :create do
						# Trick used in case there is no params (meaning none is selected)
						params[@current_object.class.to_s.underscore][:keywords_field] ||= []
            current_object.user_id = current_user.id
          end
					# Filter setting the keywords value in case the list is empty (else the application will think there is no field ...)
					before :update do
						params[@current_object.class.to_s.underscore][:keywords_field] ||= []
					end
					# 
					before :index do
						# Just to manage the permission of creation (trick avoiding one more loop)
#						params[:item_type] = @current_objects.first.class.to_s.underscore
#						@paginated_objects = @current_objects.paginate(:per_page => get_per_page_value, :page => params[:page])
						@paginated_objects = params[:controller].classify.constantize.get_da_objects_list(build_hash_from_params(params))
					end
					# Response redirecting to the show page after the create action,
					# In the case of Article, Page or Newsletter, it is redirecting to the edition page
					# in order to fill the 'body' field.
					response_for :create do |format|
						format.html { (['Article', 'Page', 'Newsletter'].include?(@current_object.class.to_s)) ? redirect_to(edit_item_path(@current_object)) : redirect_to(item_path(@current_object)) }
					end
					# Response redirecting to the show page after the edition
					response_for :update do |format|
						format.html { redirect_to item_path(@current_object) }
					end

					response_for :new, :create_fails do |format|
						format.html { render(:template => (File.exists?(RAILS_ROOT+'/app/views/'+params[:controller]+'/new.html.erb') ? params[:controller]+'/new.html.erb' : 'generic_for_item/new.html.erb')) }
					end

					response_for :edit, :update_fails do |format|
						format.html { render(:template => (File.exists?(RAILS_ROOT+'/app/views/'+params[:controller]+'/edit.html.erb') ? params[:controller]+'/edit.html.erb' : 'generic_for_item/edit.html.erb')) }
					end

					response_for :show do |format|
						format.html # index.html.erb
						format.xml { render :xml => @current_object }
						format.json { render :json => @current_object }
	        end

					response_for :index do |format|
						format.html { render(:template => (File.exists?(RAILS_ROOT+'/app/views/'+params[:controller]+'/edit.html.erb') ? params[:controller]+'/index.html.erb' : 'generic_for_items/index.html.erb')) }
						format.xml { render :xml => @current_objects }
						format.json { render :json => @current_objects }
						format.atom { render :template => "generic_for_items/index.atom.builder", :layout => false }
	        end

          response_for :destroy do |format|
            format.html { redirect_to(content_path(params[:controller])) }
          end
        end

        # Items Lists depending on Controller
				def current_objects
					@current_objects = get_items_list(params[:controller])
				end
      end

    end
    
    module InstanceMethods
			# Function allowing to get directly the content of the item, not details like title or description
			#
      # This method will return a link to the resource defining by the item.
      #
      # Usage URL :
      # /images/123/redirect_to_content
			def redirect_to_content
				# Critical for performance but important for security
				# TODO what if this item is not in fcke but not linked to a website ... (we should make restriction)
				if get_fcke_item_types.include?(params[:controller].singularize) #&& current_object.workspaces.delete_if{ |e| !e.websites.first }.size > 0
					current_object = params[:controller].classify.constantize.find(params[:id])
					if params[:controller] == 'pages'
						redirect_to root_url+current_object.title_sanitized
					elsif params[:controller] == 'bookmarks'
						redirect_to current_object.link
					elsif params[:controller] == 'cms_files'
						redirect_to current_object.cmsfile.url
					else
						redirect_to current_object.send(params[:controller].singularize).url
					end
				else
					no_permission_redirection
				end
			end
			
      # Rate the Item
      #
      # Usage :
      #
      # <tt>article.rate</tt>
      #
      # will create new rating for the item and save it
      def rate
        if rating = Rating.find(:first, :conditions =>{:user_id => current_user.id, :rateable_id => current_object.id, :rateable_type => current_object.class.to_s})
          rating.update_attributes(:rating =>params[:rated].to_i)
        else
          current_object.add_rating(Rating.new(:rating => params[:rated].to_i,:user_id => current_user.id))
        end
        current_object.update_attributes(:rates_average => Rating.average(:rating, :conditions =>{:rateable_id => current_object.id, :rateable_type => current_object.class.to_s}).to_i)
				# TODO : refresh the rate box ...
        render :nothing => true
      end
      
    end
  end
end