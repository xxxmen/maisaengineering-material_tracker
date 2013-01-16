require 'rake'
class Admin::UtilitiesController < ApplicationController
	before_filter :admin_required
	skip_before_filter :login_from_cookie
 	skip_before_filter :login_required
	
	# Stolen from the ts-delayed-delta gem's 'ts:in:delta' rake task, so
	# we don't need to load up the entire environment each time.
	def index_sphinx
    	ThinkingSphinx.context.indexed_models.collect { |model| model.constantize }.select { |model|
        	model.define_indexes
        	model.delta_indexed_by_sphinx?
      	}.each do |model|
        	model.sphinx_indexes.select { |index|
          			index.delta? && index.delta_object.respond_to?(:delayed_index)
        	}.each { |index|
          		index.delta_object.delayed_index(index.model)
        	}
		end
		
		render :text => 'Deltas Indexed!'
	end
	
	private
	
	def admin_required
		unless params[:k] == SPHINX_INDEXING_PASSWORD
			flash[:error] = "This page could not be accessed."
			redirect_to '/'
		end
	end
end
