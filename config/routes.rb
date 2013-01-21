ActionController::Routing::Routes.draw do |map|
  map.resources :groups




  # Hopefully this fixes the 'Microsoft Office Protocol Discovery' issue we
  # were having with /doc/General_Notes.doc. This should filter all requests
  # with HTTP_METHOD = 'OPTIONS' and render a 418 error (I'm a teapot),
  # preventing an Exception Notifier from being emailed EVERY time...
  # See also: app/controllers/application.rb, lib/extra_http_verbs.rb
  map.connect '*path',
                :controller => 'application',
                :action => 'options_for_mopd',
                :conditions => {:method => :options}

  map.connect '/popv_viewer', :controller => 'sessions', :action => 'login_as_popv_viewer'

  map.connect '/inventory_items/tags', :controller => "inventory_items", :action => "tags"
  map.connect '/inventory_items/edit_basket', :controller => "inventory_items", :action => "edit_basket"

  map.resources :general_references, :collection => { :search => :get }, :member => {:download => :get}
  map.resources :events
  map.resources :emails

  map.resources :cart_items
  map.resources :carts, :collection => { :search => :get, :recent_search => :get, :issue => :put, :get_order => :get, :recent => :get }
  map.connect "/get_order", :controller => "carts", :action => "get_order"

  #map.connect '/boms/current', :controller => 'boms', :action => 'current'
  #map.connect '/boms/set_current/:id', :controller => 'boms', :action => 'set_current'
  map.resources :bills, :member => { :approve => :post,
  									 :review => :post,
  									 :disapprove => :post,
  									 :unreview => :post,
  									 :request_for_quote_pdf => :get
  								   }
  map.resources :bill_items, :collection => {:create_many => :post}



  #Restful routes for all sext resources.
  map.connect '/sext/save_tabs', :controller => 'sext', :action => 'save_tabs'
  map.connect '/sext/tabs', :controller => 'sext', :action => 'tabs'
  map.connect '/sext/:resource/', :controller => 'sext', :action => 'index', :conditions => {:method => :get}
  map.connect '/sext/:resource/store', :controller => 'sext', :action => 'store', :conditions => {:method => :get}
  map.connect '/sext/:resource/:id', :controller => 'sext', :action => 'show', :conditions => {:method => :get}
  map.connect '/sext/:resource/', :controller => 'sext', :action => 'create', :conditions => {:method => :post}
  map.connect '/sext/:resource/:id', :controller => 'sext', :action => 'update', :conditions => {:method => :put}
  map.connect '/sext/:resource/:id', :controller => 'sext', :action => 'destroy', :conditions => {:method => :delete}
  map.connect "/piping/clone_class/:id", :controller => "piping", :action => "clone_class"

  map.connect "/piping/compare_piping_classes/:ids", :controller => "piping", :action => "compare_piping_classes", :format => 'json'
  map.connect "/piping/compare_piping_classes.csv/:ids", :controller => "piping", :action => "compare_piping_classes", :format => 'csv'

  map.connect "/orders/select_pos", :controller => "orders", :action => "select_pos"

  map.connect '/piping_class_details/prepend_text_to_descriptions', :controller => 'piping_class_details', :action => 'prepend_text_to_descriptions', :conditions => {:method => :put}


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  # map.connect ':controller/:action/:id.:format'
  map.connect "/", :controller => "home", :action => "index"
  map.main_menu "/menu", :controller => "home", :action => "menu"
  map.connect "/superuser", :controller => "home", :action => "superuser"
  map.connect "/changelog", :controller => "home", :action => "changelog"
  map.connect "/warehouse", :controller => "orders", :action => "warehouse"
  map.connect "/orders/add_line_item", :controller => "orders", :action => "add_line_item"
  map.connect "/remote_client/:action", :controller => "remote_client"
  map.connect "/remote_client/:action/:id", :controller => "remote_client"
  map.bill "/material_requests/bill", :controller => "material_requests", :action => "bill"
  map.bill "/material_requests/sample_csv", :controller => "material_requests", :action => "sample_csv"




  map.resources :record_changelogs, :collection => { :update_comment => :post }, :member => {:get_attachment => :get}
  map.resources :sessions
  map.resources :inventory_items, :collection => { :search => :get }
  map.resources :companies, :collection => { :search => :get }
  map.resources :units, :collection => { :search => :get }
  map.resources :quotes, :collection => { :search => :get }



  map.resources :bulk_changes, :collection => { :tables => :post, :fields => :post, :search_results => :post, :finalize_replace => :post}
  map.resources :boms, :collection => { :search => :get, :excel => :get}
  map.resources :piping, :collection => { :search => :get,
  										  :classes_service => :get,
  										  :classes_only => :get,
                        :classes_only_incl_archived => :get,
  										  :units_for_measure => :get,
  										  :piping_sizes => :get,
  										  :piping_class_details => :get,
  										  :piping_components => :get,
  										  :all_classes_pdf => :get,
  										  :notes_pdf => :get
										},
						:member => {:details_pdf => :get, :valves_pdf => :get,
              :increase_order => :post, :decrease_order => :post,
              :increase_group_order => :post, :decrease_group_order => :post}
  map.resources :piping_class_details, :collection => { :search => :get}, :member => {:add_note => :put}
  map.resources :piping_components, :collection => { :search => :get, :associated_piping_classes => :get }
  map.resources :piping_subcomponents, :collection => { :search => :get }
  map.resources :piping_specifications, :collection => { :search => :get }
  map.resources :piping_descriptions, :collection => { :search => :get }
  map.resources :user_notes, :collection => { :search => :get }
  map.resources :valve_components, :collection => { :search => :get }
  map.resources :manufacturers, :collection => { :search => :get }
  map.resources :piping_notes, :collection => { :search => :get }
  map.connect "/valves/clone/:id", :controller => "valves", :action => "clone"
  map.resources :valves,
  	:collection => {
  		:search => :get,
  		:all_pdf => :get,
  		:comparison_pdf => :get,
  		:related_valve_components => :get,
  		:related_manufacturers => :get,
  		:related_old_manufacturers => :get,
  		:related_piping_classes => :get,
  		:related_piping_references => :get,
      :valve_components => :get,
  		:pdf => :get,
      :supersede_manufacturer => :post,
      :undo_supersede_manufacturer => :post,
  		:add_manufacturer => :post,
  		:edit_manufacturer => :put,
  		:delete_manufacturer => :delete
  	},
  	:member => { :archive => :put }


  map.resources :popv, :collection => { :search => :get, :upload_reference_documents => :post, :popv_user_guide => :get }
  map.resources :employees, :collection => { :search => :get }
    map.resources :orders,
        :collection => {
            :test => :get,
            :search => :get,
            :complete_vendor => :get
        },
        :member => {
            :complete_employee => :get
        }
  map.resources :reminders, :collection => { :search => :get }
  map.resources :reference_number_types
  map.resources :vendors, :collection => { :search => :get }
  map.resources :po_statuses, :collection => { :search => :get }
  map.resources :vendor_groups, :collection => { :search => :get }
  map.resources :material_requests,
  	:collection => { :search => :get },
  	:member => {
     :update_items_from_request => :get,
      :pdf => :get,
  		:acknowledge => :get,
  		:vendor_email => :get,
  		:new_from_bom => :get,
  		:duplicate => :get,
  		:duplicate_with_items => :get,
  		:get_purchaser_group => :get
  	}
  map.resources :requested_line_items

  map.resources :piping_references
  map.resources :piping_reference_attachings,
  	:collection => {
  		:create_with_piping_reference => :post
  	}

  map.resources :tickets, :collection => { :search => :get }
  map.resources :links

  map.signup '/signup', :controller => 'employees', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.reports '/reports', :controller => "reports", :action => "index"
  map.connect '/reports/email', :controller => "reports", :action => "email"
  map.csv '/csv', :controller => "reports", :action => "csv"
  map.contact_us '/contact_us', :controller => "home", :action => "contact_us"

  map.connect '/docs', :controller => 'application', :action => 'docs'

  map.connect '/admin/new_message', :controller => 'admin/messages', :action => 'new_admin_message'
  map.connect '/admin/index_sphinx', :controller => 'admin/utilities', :action => 'index_sphinx'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action'
  map.connect ':controller', :action => "index"
end
