module ItemsHelper

  # Rating Item
  # 
  # Usage:
  # 
  # <tt>item_rate(article_object)</tt>
  # 
  # will return the javascript for rating the object
  # 
  # Parameters:
  # 
  # - object: Item Object ex:article,image......
  # - rerate: true or false
  # - onRate: Ajax Request to Store Rating with parameters
  # - locked: true or false to lock or unlock rating on item
  def item_rate(object, params = {})
    params = {
      :rerate => false,
  		:onRate => "function(element, info) {
  			new Ajax.Request('#{rate_item_path(object)}', {
  				parameters: info
  			})}"
    } if params.empty?

    params_to_js_hash = '{' + params.collect { |k, v| "#{k}: #{v}" }.join(', ') + '}'
    div_id = "rating_#{object.class.to_s.underscore}_#{object.id}_#{rand(1000)}"
    content_tag(:div, nil, { :id => div_id, :class => :rating }) +
      javascript_tag(%{
			new Starbox("#{div_id}", #{object.rating}, #{params_to_js_hash});
      })
  end

  # Rating Item Locked
  #
  # Usage:
  #
  # <tt>item_rate_locked(article_object)</tt>
  #
  # will return the rating for item, rating item not possible
  def item_rate_locked(object)
    item_rate(object, :locked => true)
  end


	# Form For Item(Default Fields)
  #
  # Usage:
  #
  # <tt>form_for_item article_object, title do |f| </tt>
  # <tt>end</tt>
  #
  #  will return the form for default item fields like 'title', 'description', 'keywords', 'workspaces'
  #
  #  Parameters:
  #
  #  object: item_object:
  #  title : title of form
  #  &block : item specific form elements to bind to item form
  def form_for_item(object, title = '', &block)
		concat(render(:partial => "items/form", :locals => { :block => block, :title => title }), block.binding)
  end

	 

	# Define the common information of the show of an item
	def item_show(parameters, &block)
    concat\
      render( :partial => "items/show",
      :locals => {  :object => parameters[:object],
        :title => parameters[:title],
        :block => block                 } ),
      block.binding
  end
  
	# FCKEditor Field for Workspace & Article
  #
  # Usage:
  #
  # f.advanced_editor(:body, 'Article' + ' * :')
  #
  # will return the fckeditor for article body
	def advanced_editor_on(object, attribute)
    '<script type="text/javascript" src="/fckeditor/fckeditor.js"></script>' +
      javascript_tag(%{
        var oFCKeditor = new FCKeditor('#{object.class.to_s.underscore}_#{attribute}', '730px', '350px') ;
        oFCKeditor.BasePath = "/fckeditor/" ;
				oFCKeditor.Config['ImageUploadURL'] = "/fckuploads?item_type=#{object.class}&id=#{object.new_record? ? current_user.login+'_'+current_user.id.to_s : object.id}&type=Image";
        oFCKeditor.Config['DefaultLanguage'] = '#{I18n.locale.split('-')[0]}' ;
        oFCKeditor.ReplaceTextarea() ;
        
      })
  end

  # Item Status Fields
  #
  # Usage:
  #
  # <tt>item_status_fields(form, article)</tt>
  #
  # will return item status fields for the artile
  def item_status_fields(form, item)
    render :partial => "items/status", :locals => { :f => form, :item => item }
  end

	# Item Category Fields
  #
  # Usage:
  #
  # <tt>item_category_fields(form, article)</tt>
  #
  # will return item category fields for the artile
  def item_category_fields(form, item)
    render :partial => "items/category", :locals => { :f => form, :item => item }
	end

	# Item Keywords Fields
  #
  # Usage:
  #
  # <tt>item_keywords_fields(form, article)</tt>
  #
  # will return item keywords fields for the artile
	def item_keywords_fields(form, item)
    render :partial => "items/keywords_fields", :locals => { :f => form, :item => item }
	end

	# Displays Item Type in Tabs with Items List
  #
  # Usage:
  #
  # display_tabs_items_list('article', paginated_objects, ajax_items_path('article'))
  #
  # will return the tabs for item_type passed
  #
  # Parameters:
  #
  # - item_type: can be any item type ex:article,image......
  # - items_list: list of items to be displayed for the tab
  # - ajax_url: ajax item path for the item_type
  def display_tabs_items_list(item_type, items_list, ajax_url)
		item_types = get_allowed_item_types(current_workspace)
		item_type ||= item_types.first.to_s.pluralize
    content = String.new
		#raise item_types.inspect
		if item_type.blank?
			return I18n.t('item.common_word.no_item_types')
		else
			item_types.map{ |item| item.camelize }.each do |item_model|
     
        # each li got a different content
        li_content = String.new
        
				url = ajax_items_path(item_model.classify.constantize)
				item_page = item_model.underscore.pluralize
				options = {}
				options[:class] = 'selected' if (item_type == item_page)
				options[:id] = item_model.underscore

        tip_option = {}
        tip_option[:id] = "tip_" + item_model.underscore
        tip_option[:style] = "display:none;"
        tip_option[:class] = "tipTitle"
        
        li_content += link_to_remote(image_tag(item_model.classify.constantize.icon_48),:method=>:get, :update => "object-list", :url => url, :before => "selectItemTab('" + item_model.underscore + "')")
        li_content += content_tag(:div, item_model.classify.constantize.label , tip_option)
        li_content += "<script type='text/javascript'>
                      //<![CDATA[
                        new Tip('" + item_model.underscore + "',  $('tip_" + item_model.underscore + "'),
                            { effect: 'appear',
                              duration: 1,
                              delay:0,
                              hook: { target: 'topMiddle', tip: 'bottomMiddle' },
                              hideOn: { element: 'tip', event: 'mouseout' },
                              stem: 'bottomMiddle',
                              hideOthers: 'true',
                              hideAfter: 1,
                              width: 'auto',
                              border: 1,
                              offset: { x: 0, y: 3 },
                              radius: 0
                            });
                      //]]>
                    </script>"
				content += content_tag(:li,	li_content,	options)
			end
			return content_tag(:ul, content, :id => :tabs) + display_items_list(items_list, ajax_url)
		end
	end

  # Items List
  #
  # Usage:
  #
  # <tt>display_items_list(items_list, ajax_url)</tt>
  #
  # will return list of items for given item_type with div 'object-list'
  #
  # - items_list: list of items to be displayed for the tab
  # - ajax_url: ajax item path for the item_type
	def display_items_list(items_list, ajax_url, partial_used='items/items_list')
		if items_list.first
	    content = render :partial => partial_used, :locals => { :ajax_url => ajax_url }
      content_tag(:div, content, :id => "object-list")
		else
			render :text => "<br /><br />"+I18n.t('item.common_word.list_empty')
		end
	end

	# Items List
  #
  # Usage:
  #
  # <tt>display_items_in_list(items_list)</tt>
  #
  # will return list of items for given item_type with div 'object-list'
  #
  # - items_list: list of items to be displayed for the tab
  def display_item_in_list(items_list, partial_used='items/item_in_list')
		@i = 0
	  render :partial => partial_used, :collection => items_list
  end

  # Display Item in List for Editor
	def display_item_in_list_for_editor
		display_item_list('items/item_in_list_for_editor')
	end

  # Classify Bar for Ordering, Filtering Items
  # 
  # Usage:
  # 
  # <tt>display_classify_bar(['created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'], ajax_url, 'object-list')</tt>
  # 
  # will return classify bar for item list with option to filter on fields
  # 
  # Parameters:
  # 
  # - ordering_fields_list: 'created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'
  # - ajax_url: url to be passed to be called on click of item
  # - refreshed_dv: objects-list
  # - partial_used : 'items/classify_bar'
	def display_classify_bar(ordering_fields_list, ajax_url, refreshed_div, partial_used='items/classify_bar')
		render :partial => partial_used, :locals => {
      :ordering_fields_list => ordering_fields_list,
      :ajax_url => ajax_url,
      :refreshed_div => refreshed_div
		}
	end

  # Ajax Item Path
  #
  # Usage:
  #
  # <tt>get_ajax_item_path('article')</tt>
  # 
  # Will return the ajax_items_path depending on the current_worksapces
  def get_ajax_item_path(item_type)
    item_type ||=  get_allowed_item_types(current_workspace).first.pluralize
    url = current_workspace ? ajax_items_path(item_type) +"&page=" : ajax_items_path(item_type) +"?page="
    return url
  end

  # Safe Url for Classify Bar
	def safe_url(url, params)
		# TODO generic allowing to replace params in url
		# trick, work just for classify_bar case
		prev_params = (a=request.url.split('?')).size > 1 ? '?'+a.last : ''
		#raise request.url.split('?').size.inspect
		return (url+prev_params).split(params.first.split('=').first).first + ((url+prev_params).include?('?') ? '&' : '?') +params.join('&')
	end

  # Render Specific Partial according to Item Type passed
  #
  # Usage get_specific_partial('article', preview, article_object)
  #
  # will render the partial depending on the item_type
  def get_specific_partial(item_type, partial, object)
    if File.exists?(RAILS_ROOT+'/app/views/'+object.class.to_s.downcase.pluralize.underscore+"/_#{partial}.html.erb")
      render :partial => "#{object.class.to_s.downcase.pluralize.underscore}/#{partial}", :object => object
    else
      render :nothing => true
    end
  end
	
end