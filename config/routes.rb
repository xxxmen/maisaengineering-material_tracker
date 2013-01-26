MaterialTracker::Application.routes.draw do
  resources :groups
  match '*path' => 'application#options_for_mopd', :via => :options
  match '/popv_viewer' => 'sessions#login_as_popv_viewer'
  match '/inventory_items/tags' => 'inventory_items#tags'
  match '/inventory_items/edit_basket' => 'inventory_items#edit_basket'
  resources :general_references do
    collection do
      get :search
    end
    member do
      get :download
    end

  end

  resources :events
  resources :emails
  resources :cart_items
  resources :carts do
    collection do
      get :search
      get :recent_search
      put :issue
      get :get_order
      get :recent
    end


  end

  match '/get_order' => 'carts#get_order'
  resources :bills do

    member do
      post :approve
      post :review
      post :disapprove
      post :unreview
      get :request_for_quote_pdf
    end

  end

  resources :bill_items do
    collection do
      post :create_many
    end


  end

  match '/sext/save_tabs' => 'sext#save_tabs'
  match '/sext/tabs' => 'sext#tabs'
  match '/sext/:resource/' => 'sext#index', :via => :get
  match '/sext/:resource/store' => 'sext#store', :via => :get
  match '/sext/:resource/:id' => 'sext#show', :via => :get
  match '/sext/:resource/' => 'sext#create', :via => :post
  match '/sext/:resource/:id' => 'sext#update', :via => :put
  match '/sext/:resource/:id' => 'sext#destroy', :via => :delete
  match '/piping/clone_class/:id' => 'piping#clone_class'
  match '/piping/compare_piping_classes/:ids' => 'piping#compare_piping_classes', :format => 'json'
  match '/piping/compare_piping_classes.csv/:ids' => 'piping#compare_piping_classes', :format => 'csv'
  match '/orders/select_pos' => 'orders#select_pos'
  match '/piping_class_details/prepend_text_to_descriptions' => 'piping_class_details#prepend_text_to_descriptions', :via => :put
  match '/' => 'home#index'
  match '/menu' => 'home#menu', :as => :main_menu
  match '/superuser' => 'home#superuser'
  match '/changelog' => 'home#changelog'
  match '/warehouse' => 'orders#warehouse'
  match '/orders/add_line_item' => 'orders#add_line_item'
  match '/remote_client/:action' => 'remote_client#index'
  match '/remote_client/:action/:id' => 'remote_client#index'
  match '/material_requests/bill' => 'material_requests#bill', :as => :bill
  match '/material_requests/sample_csv' => 'material_requests#sample_csv', :as => :bill
  resources :record_changelogs do
    collection do
      post :update_comment
    end
    member do
      get :get_attachment
    end

  end

  resources :sessions
  resources :inventory_items do
    collection do
      get :search
    end


  end

  resources :companies do
    collection do
      get :search
    end


  end

  resources :units do
    collection do
      get :search
    end


  end

  resources :quotes do
    collection do
      get :search
    end


  end

  resources :bulk_changes do
    collection do
      post :tables
      post :fields
      post :search_results
      post :finalize_replace
    end


  end

  resources :boms do
    collection do
      get :search
      get :excel
    end


  end

  resources :piping do
    collection do
      get :search
      get :classes_service
      get :classes_only
      get :classes_only_incl_archived
      get :units_for_measure
      get :piping_sizes
      get :piping_class_details
      get :piping_components
      get :all_classes_pdf
      get :notes_pdf
    end
    member do
      get :details_pdf
      get :valves_pdf
      post :increase_order
      post :decrease_order
      post :increase_group_order
      post :decrease_group_order
    end

  end

  resources :piping_class_details do
    collection do
      get :search
    end
    member do
      put :add_note
    end

  end

  resources :piping_components do
    collection do
      get :search
      get :associated_piping_classes
    end


  end

  resources :piping_subcomponents do
    collection do
      get :search
    end


  end

  resources :piping_specifications do
    collection do
      get :search
    end


  end

  resources :piping_descriptions do
    collection do
      get :search
    end


  end

  resources :user_notes do
    collection do
      get :search
    end


  end

  resources :valve_components do
    collection do
      get :search
    end


  end

  resources :manufacturers do
    collection do
      get :search
    end


  end

  resources :piping_notes do
    collection do
      get :search
    end


  end

  match '/valves/clone/:id' => 'valves#clone'
  resources :valves do
    collection do
      get :search
      get :all_pdf
      get :comparison_pdf
      get :related_valve_components
      get :related_manufacturers
      get :related_old_manufacturers
      get :related_piping_classes
      get :related_piping_references
      get :valve_components
      get :pdf
      post :supersede_manufacturer
      post :undo_supersede_manufacturer
      post :add_manufacturer
      put :edit_manufacturer
      delete :delete_manufacturer
    end
    member do
      put :archive
    end

  end

  resources :popv do
    collection do
      get :search
      post :upload_reference_documents
      get :popv_user_guide
    end


  end

  resources :employees do
    collection do
      get :search
    end


  end

  resources :orders do
    collection do
      get :test
      get :search
      get :complete_vendor
    end
    member do
      get :complete_employee
    end

  end

  resources :reminders do
    collection do
      get :search
    end


  end

  resources :reference_number_types
  resources :vendors do
    collection do
      get :search
    end


  end

  resources :po_statuses do
    collection do
      get :search
    end


  end

  resources :vendor_groups do
    collection do
      get :search
    end


  end

  resources :material_requests do
    collection do
      get :search
    end
    member do
      get :update_items_from_request
      get :pdf
      get :acknowledge
      get :vendor_email
      get :new_from_bom
      get :duplicate
      get :duplicate_with_items
      get :get_purchaser_group
    end

  end

  resources :requested_line_items
  resources :piping_references
  resources :piping_reference_attachings do
    collection do
      post :create_with_piping_reference
    end


  end

  resources :tickets do
    collection do
      get :search
    end


  end

  resources :links
  match '/signup' => 'employees#new', :as => :signup
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/reports' => 'reports#index', :as => :reports
  match '/reports/email' => 'reports#email'
  match '/csv' => 'reports#csv', :as => :csv
  match '/contact_us' => 'home#contact_us', :as => :contact_us
  match '/docs' => 'application#docs'
  match '/admin/new_message' => 'admin/messages#new_admin_message'
  match '/admin/index_sphinx' => 'admin/utilities#index_sphinx'
  match '/:controller(/:action(/:id))'
  match ':controller/:action' => '#index'
  match ':controller' => '#index'
end