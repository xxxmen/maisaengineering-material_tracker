class VendorGroupsController < ApplicationController
    before_filter :find_vendor_group, :only => [:edit, :update, :destroy]
    before_filter :find_all_vendors, :only => [:edit, :update, :destroy, :new, :create]
    before_filter :check_query, :only => [:search]
    
    def index
        @vendor_groups = VendorGroup.list(params, :order => "vendor_groups.name")
    end
    
    def search
        @vendor_groups = VendorGroup.full_text_search(params)
        return_search(@vendor_groups)
    end
    
    def new
        @vendor_group = VendorGroup.new
        render :action => :edit
    end
    
    def create
        @vendor_group = VendorGroup.new
        save_and_show!
    rescue ActiveRecord::RecordInvalid
        flash.now[:error] = "There was a problem saving this vendor_group." 
        render :action => :edit
    end
    
    def update
        save_and_show!
    rescue ActiveRecord::RecordInvalid
        flash.now[:error] = "There was a problem saving this vendor_group."
        render :action => "edit"
    end
    
    def destroy
        @vendor_group.vendors.clear
        @vendor_group.save!
        @vendor_group.destroy
        redirect_to vendor_groups_path
    end
    
    private
    def save_and_show!
        @vendor_group.attributes = params[:vendor_group]
        @vendor_group.vendors.clear
        @vendors.each{|v| @vendor_group.vendors.push v if params["vendor_#{v.id}"] }
        @vendor_group.save!
        flash[:notice] = "<a href=\"#{edit_vendor_group_path(@vendor_group)}\">#{@vendor_group.name}</a> was saved successfully at #{current_time}".html_safe
        redirect_to vendor_groups_path   
    end
    
    def find_vendor_group
        @vendor_group = VendorGroup.find(params[:id])
    end
    
    def find_all_vendors
        @vendors = Vendor.find(:all, :order => "name")
        @vendors_of_vendor_group = @vendor_group ? @vendor_group.vendors : []
    end
end
