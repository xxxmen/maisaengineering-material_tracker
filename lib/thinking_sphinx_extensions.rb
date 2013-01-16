# Adam Grant - (2009-06-18)
# This declaration overwrites the current #search method to #search_with_sphinx
# so that it doesn't conflict with Listable Module's #search method already 
# built into the site.
require 'thinking_sphinx'

module ThinkingSphinx
  module SearchMethods
    module ClassMethods
    	instance_eval {
	    	alias_method :search_with_sphinx, :search
			remove_method :search
		}
	end
  end
end

