class InventoryItemsController < ApplicationController
  before_filter :resource_enabled?
  before_filter :check_query, :only => [ :search ]
  before_filter :find_inventory_item, :only => [:show, :edit, :update, :add_to_cart]
  before_filter :find_basket
  before_filter :change_params_for_auto_complete_for_vendor_name, :only => [:auto_complete_for_vendor_name]
  
  auto_complete_for :vendor, :name
  
  def index
    InventoryItem.filter(params) do
      @inventory_items = InventoryItem.list(params)
    end
  end
  
  def edit_basket
    index
  end
  
  def search
    InventoryItem.filter(params) do
      @inventory_items = InventoryItem.full_text_search(params)
      return_search(@inventory_items)
    end
  end
  
  def tags
    @tags = Tag.find(:all, :order => "name").map(&:name)
  end
  
  def update_tags
    @inventory_item = InventoryItem.find(params[:id])
    @inventory_item.tag_with(params[:tags])
  end
  
  def add_to_cart
    @cart = current_employee.last_cart
    @cart_item = @cart.create_or_add(:inventory_item_id => params[:id], :quantity => 1)
    render :update do |page|
      page << "alert('Successfully added this item to your cart')"
    end
  end

  def new
    @inventory_item = InventoryItem.new
    render :action => :edit
  end

  def create
    @inventory_item = InventoryItem.new(params[:inventory_item])
    save_and_show!
  end

  def update
    save_and_show!
  end
  
  private
  def save_and_show!
    @inventory_item.update_attributes!(params[:inventory_item])
    flash[:notice] = msg_for("Inventory Item", @inventory_item.description, @inventory_item)
    redirect_to inventory_items_path
  rescue ActiveRecord::RecordInvalid
    flash[:error] = "Inventory Item could not be saved properly due to error(s)"
    render :action => "edit"
  end
  
  def find_inventory_item
    @inventory_item = InventoryItem.find(params[:id])
  end
  
  def find_basket
    @basket = Basket.for_employee(current_employee)
  end
  
  def change_params_for_auto_complete_for_vendor_name
    params[:vendor] ||= {}
    params[:vendor][:name] = params[:inventory_item][:vendor_name]
  end
end
