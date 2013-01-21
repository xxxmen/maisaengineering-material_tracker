AttributesFor.valid :request, { :tracking => "L124131",
                                :unit_id => 1,
                                :planner_id => 4,
                                :year => "2007",
                                :requested_by_id => 5 }, :class_name => "MaterialRequest"
AttributesFor.invalid :request, { :tracking => "L124131",
                                  :unit_id => 999,
                                  :planner_id => 4,
                                  :year => "2007" }, :class_name => "MaterialRequest"

AttributesFor.valid :req_item, { :quantity => 1, :material_description => "None" }, :class_name => "RequestedLineItem"                                  

AttributesFor.valid :order, :description => "Potions, hi-potions, elixers, phoenix downs, and ethers",
                            :deliver_to => "Moogle Express",
                            :po_no => "12461325",
                            :tracking => "L124131",
                            :unit_id => 1
                                       
AttributesFor.valid :employee, :badge_no => "1423",
                               :first_name => "Cloud",
                               :last_name => "Strife",
                               :company_id => 1

AttributesFor.valid :company, :name => "Microsoft"                                       
AttributesFor.invalid :company, :name => nil

AttributesFor.valid :inventory_item, :warehouse_name => "Test", :stock_no_id => 1

AttributesFor.valid :cart, :employee_id => 1
AttributesFor.valid :cart_item, :cart_id => 1, :quantity => 1, :inventory_item_id => 1