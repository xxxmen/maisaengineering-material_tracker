class BasketsController < ApplicationController
  # params[:basket_item] = attributes for a basket item
  # Creates a new basket_item for the current employee's basket
  # AJAX will re-render the basket on the user's screen
  def add_item
    @basket = Basket.for_employee(current_employee)
    @basket_item = BasketItem.new(params[:basket_item])
    @basket.basket_items << @basket_item
    @basket_item.save
    
    render :update do |page|
      if @basket_item.valid?
        page.replace "basket", :partial => "inventory_items/basket", :locals => { :basket => @basket }
        page.visual_effect :highlight, dom_id(@basket_item)
      end
    end
  end  
  
  # params[:basket_item_id] = id of basket_item to delete
  # Destroys the basket_item and then removes it from the page via AJAX
  def del_item
    @basket = Basket.for_employee(current_employee)
    @basket_item = @basket.basket_items.find(params[:basket_item_id])
    @basket_item.destroy
    render :update do |page|
      page.replace "basket", :partial => "inventory_items/basket", :locals => { :basket => @basket }
    end
  end

  # DOES NOT actually delete the basket
  # Instead, clears the basket by deleting all line items
  def delete
    @basket = Basket.for_employee(current_employee)
    @basket.basket_items.each { |basket_item| basket_item.destroy }
    render :update do |page|
      page.replace "basket", :partial => "inventory_items/basket", :locals => { :basket => @basket }
    end
  end
end
