class UsersController < SextController
  def index
  	#Put your own code here which modifies the index action
  	#Make sure you have a route in routes such as:
  	# map.resources 'users', :path_prefix => 'sext/?resource=users'
  	super()
  end
end
