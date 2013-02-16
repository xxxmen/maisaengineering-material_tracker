# Extends a class to make it listable and searchable
# So you have access to an easy ordering link, searching interface, and listing interface
#
# Any customizations needed?  Use the with_scope method in your AR model:
# with_scope(:find => { :conditions => "user_id = 10" }) do
#   Person.list(params)
# end
#
# Example:
#   # In your model
#   class Person < ActiveRecord::Base
#     acts_as_ferret
#     extend Listable::ModelHelper  # you can use include Searchable also
#     PERPAGE = 100
#   end
#
#   # In your view :
#   class ApplicationHelper
#     include Listable::ViewHelper
#   end
#
#   <%= link_to_sort "Name", "people.name" %>
#
#   # In your controllers:
#   Person.search(params)
#   Person.list(params)

module Listable

  module ViewHelper
    def link_to_sort(name, order, options = {})
      def_sort = options[:sort] || "asc"
      undef_sort = def_sort.to_s == "asc" ? "desc" : "asc"
      extras = options[:include] || []

      new_url = {}

      new_url.merge!(:action => params[:action])
      new_url.merge!(:q => params[:q]) if params.has_key?(:q)  # query (search)
      new_url.merge!(:c => params[:c]) if params.has_key?(:c)  # per-page count
      new_url.merge!(:o => order)

      if params[:s] == nil || params[:o] != order.to_s || params[:s] == undef_sort
        new_url.merge!(:s => def_sort.to_s)
      else
        new_url.merge!(:s => undef_sort)
      end
      # Don't remember which page you're on, restart!
      # new_url.merge!(:p => params[:p]) if params.has_key?(:p)

      extras.each { |e| new_url.merge!(e => params[e]) if params.has_key?(e) }

      link_to(name, new_url) + " " +
      get_order_image(order)
    end

    def get_order_image(field)
      if params[:o] != field
        return image_tag('none.gif')
      elsif params[:s].nil? || params[:s] == "asc"
        return image_tag('ascending.gif')
      else
       return image_tag('descending.gif')
      end
    end
  end

  module ModelHelper
    # In case a class includes this instead of extending it
    # This will force an 'extend' and add 'search_for' as a class method
    @@order_only = []

    def order_only(*columns)
      @@order_only = []
      columns.each do |c|
        @@order_only << c.to_s
      end
    end

    # Options include:
    # :order => is your default column to order by
    # :sort => is your default sort order if the :order option matches current order
    # :include => should be an array of other models to include in the list
    def list(params = {}, options = {})
      # Prevents SQL injection
      if @@order_only.size > 0 && !@@order_only.include?(params[:o])
        params[:o] = nil
      end

      order = params[:o] || options[:order] || "#{table_name}.id"
      options[:sort] = nil if order != options[:order]

      # Get rid of params[:s] if someone's trying to do SQL injection
      params[:s] = nil if !params[:s].blank? && !["asc", "desc"].include?(params[:s])

      sort = params[:s] || options[:sort] || "asc"
      #page = params[:p] || 1
      # will_paginate by default passes page parameter to params
      page = params[:page] || params[:p] || 1
      includes = options[:include] || []
      order = order.to_s + " " + sort
      count = params[:c] && (params[:c].to_i > 0) ? params[:c].to_i : self::PERPAGE

      #self.find(:all, :order => order, :page => { :size => count, :current => page }, :include => includes)
      self.includes(includes).order(order).paginate(page: page, per_page: count)
    end

# 	 Original Acts_as_ferret search method.  (2009-06-18)
#    def search(params = {}, options = {})
#      query = params[:q] || ""    
#      query = query.split(/,| OR /).map { |phrase| Listable::ModelHelper.escape_and_query(phrase) }.join(" OR ")
#      ids = self.find_id_by_contents(query, :limit => 20000)[1].map { |h| h[:id] }
#      
#      with_scope(:find => { :conditions => ["#{self.table_name}.id in ( ? )", ids] }) do
#        self.list(params, options)
#      end
#    end


	# New Sphinx Searching Method (2009-06-18)
	def full_text_search(params = {}, options = {})
      query = params[:q] || ""
     page = params[:p] || 1
      #limit = params[:c] && (params[:c].to_i > 0) ? params[:c].to_i : self::PERPAGE
      # Searches using ThinkingSphinx indexes with match_mode == boolean for 
      # enhanced searching:
      # (http://www.sphinxsearch.com/docs/current.html#extended-syntax)
      record_ids = self.search_for_ids(query,
      	 :match_mode => :all,
      	 :star => true,
      	 :page => 1,
      	 #:per_page => 20000,
      	 #:max_matches => 20000,
      	 #:comment => "#{self.class_name}") #http://apidock.com/rails/ActiveRecord/Base/class_name/class
         # searchd error (status: 1): per-query max_matches=20000 out of bounds (per-server max_matches=1000)
         # if you want 20000 configure it in sphinx.yml or production.sphinx.yml
         :per_page => 1000,
         :max_matches => 1000,
         :comment => "#{self.table_name}")

#      ids = records.map {|record| record[:id] unless record.nil? }

      # This really isn't needed for Sphinx, since it can accept :conditions,
      # :includes, :order, etc. (anything that ActiveRecord can do pretty much)
      # but we will use the existing methods that ferret used for compatability
      # reasons.
      #with_scope(:find => { :conditions => ["#{self.table_name}.id in (?)", record_ids] }) do
       # self.list(params, options)
      #end
    where("#{self.table_name}.id in (?)", record_ids).list(params, options)
	end

    def self.escape_and_query(query)
      query.split(" AND ").map { |words| words.split(' ') }.flatten.map { |w| Listable::ModelHelper.escape_search(w) }.join(' AND ')
    end

    def self.escape_search(string)
      string.gsub!(/#|\/|,/, '') # take out pound signs, slashes, and commas

      if string =~ /^\d+$/
        return "(#{string} OR *#{string}*)"
      elsif ['AND', 'OR', 'NOT'].include?(string)
        return "'#{string}'"
      else
        return "*#{string}*"
      end
    end
  end

end
