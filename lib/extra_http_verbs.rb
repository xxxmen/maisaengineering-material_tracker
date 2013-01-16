# Hopefully this fixes the 'Microsoft Office Protocol Discovery' issue we 
# were having with /doc/General_Notes.doc. This should filter all requests 
# with HTTP_METHOD = 'OPTIONS' and render a 418 error (I'm a teapot), 
# preventing an Exception Notifier from being emailed EVERY time...
# See also: config/routes.rb, app/controllers/application.rb
module ActionController
  module Routing
    HTTP_METHODS = [:get, :head, :post, :put, :delete, :options]
  end
end