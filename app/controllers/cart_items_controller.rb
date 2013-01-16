class CartItemsController < ApplicationController
  def create
    @cart = current_employee.last_cart
    @cart_item = @cart.create_or_add(params[:cart_item])
    render :update do |page|
      if @cart_item.valid?
        page.replace "cart", :partial => "carts/cart", :locals => { :cart => @cart }
        page.visual_effect :highlight, dom_id(@cart_item)
      end
    end
  end
  
  def update
    @cart_item = CartItem.find(params[:id])
    @cart_item.update_attributes!(params[:cart_item])
    render :content_type => "text/javascript", :text => @cart_item.to_json
  end
  
  def destroy
    @cart = current_employee.last_cart
    @cart_item = CartItem.find(params[:id])
    @cart_item.destroy
    render :update do |page|
      page.replace "cart", :partial => "carts/cart", :locals => { :cart => @cart }
    end
  end
end
