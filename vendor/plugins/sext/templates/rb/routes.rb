ActionController::Routing::Routes.draw do |map|
  map.resources :sessions
  
  #this is the route to the html file
  map.connect '/', :controller => "sext", :action => "index"
  
  #To use the users_controller instead of the sext_controller, do this:
  #map.resources 'users', :path_prefix => 'sext/?resource=users'
  
  #Restful routes for ALL sext resources.
  map.connect '/sext/:resource/', :controller => "sext", :action => "index", :conditions => {:method => :get}
  map.connect '/sext/:resource/:id', :controller => "sext", :action => "show", :conditions => {:method => :get}
  map.connect '/sext/:resource/', :controller => "sext", :action => "create", :conditions => {:method => :post}
  map.connect '/sext/:resource/:id', :controller => "sext", :action => "update", :conditions => {:method => :put}
  map.connect '/sext/:resource/:id', :controller => "sext", :action => "destroy", :conditions => {:method => :delete}
  
  map.connect ':controller/:resource/:action/:id'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
