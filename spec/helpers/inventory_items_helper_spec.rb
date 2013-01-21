require File.dirname(__FILE__) + '/../spec_helper'
include InventoryItemsHelper

describe InventoryItemsHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should include the InventoryItemsHelper" do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(InventoryItemsHelper)
  end
  
end
