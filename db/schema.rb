# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120727213629) do

  create_table "admin_messages", :force => true do |t|
    t.string   "text"
    t.datetime "display_until_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "basket_items", :force => true do |t|
    t.integer  "basket_id"
    t.integer  "inventory_item_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "baskets", :force => true do |t|
    t.integer  "employee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bill_items", :force => true do |t|
    t.integer  "bill_id"
    t.integer  "quantity"
    t.integer  "piping_class_detail_id"
    t.integer  "item_no"
    t.string   "unit_of_measure"
    t.text     "description"
    t.text     "notes"
    t.boolean  "manual",                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "size_1"
    t.string   "size_2"
    t.integer  "line_num"
  end

  create_table "bills", :force => true do |t|
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "special_instructions"
    t.text     "description"
    t.string   "status"
    t.string   "tracking"
    t.string   "work_order"
    t.date     "required_on"
    t.string   "suggested_vendor"
    t.string   "delivery_type"
    t.integer  "unit_id"
    t.string   "process"
    t.string   "mes"
    t.integer  "updated_by"
    t.integer  "material_request_id"
    t.boolean  "superseded"
    t.string   "requestor_department",         :default => "ENGINEERING"
    t.string   "deliver_to"
    t.string   "attention"
    t.string   "will_call"
    t.string   "will_call_extension_or_radio"
    t.boolean  "stage"
    t.string   "default_piping_size"
    t.string   "ticket"
    t.integer  "approved_by"
    t.string   "reference_number_1_type"
    t.string   "reference_number_1"
    t.string   "reference_number_2_type"
    t.string   "reference_number_2"
    t.string   "reference_number_3_type"
    t.string   "reference_number_3"
  end

  create_table "cart_items", :force => true do |t|
    t.integer  "quantity"
    t.integer  "cart_id"
    t.integer  "inventory_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
  end

  create_table "carts", :force => true do |t|
    t.integer  "employee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
    t.string   "year"
    t.string   "telephone"
    t.string   "deliver_to"
    t.integer  "purchaser_id"
    t.integer  "planner_id"
    t.text     "notes"
    t.integer  "requested_by_id"
    t.integer  "state",               :default => 0
    t.string   "tracking_no"
    t.date     "date_requested"
    t.datetime "sent_at"
    t.datetime "received_at"
    t.string   "need_by"
    t.integer  "material_request_id"
    t.boolean  "delta",               :default => true, :null => false
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "telephone"
    t.string   "fax"
    t.text     "notes"
    t.integer  "lock_version", :default => 0
    t.datetime "updated_at"
    t.boolean  "delta",        :default => true, :null => false
  end

  create_table "emails", :force => true do |t|
    t.integer  "employee_id"
    t.text     "content"
    t.text     "to"
    t.text     "from"
    t.text     "subject"
    t.datetime "created_at"
  end

  create_table "employees", :force => true do |t|
    t.integer  "badge_no"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "mi"
    t.string   "login"
    t.integer  "company_id"
    t.string   "email"
    t.string   "telephone"
    t.integer  "lock_version",                            :default => 0
    t.datetime "updated_at"
    t.integer  "role",                                    :default => 1
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "start_page",                              :default => 1
    t.boolean  "seen_updates",                            :default => true
    t.boolean  "direct_search",                           :default => false
    t.string   "fax"
    t.boolean  "buyer",                                   :default => false
    t.boolean  "archived",                                :default => false
    t.integer  "current_bom_id"
    t.text     "current_popv_tabs"
    t.boolean  "popv_enabled"
    t.integer  "group_id"
    t.string   "bom_xls_file"
    t.boolean  "delta",                                   :default => true,  :null => false
  end

  create_table "events", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "recordable_id"
    t.string   "recordable_type"
    t.datetime "created_at"
    t.text     "description"
    t.datetime "updated_at"
  end

  create_table "folders", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "general_notes", :force => true do |t|
    t.datetime "created_at"
    t.string   "section_name"
    t.integer  "section_no"
    t.text     "section_text"
    t.datetime "updated_at"
  end

  create_table "general_references", :force => true do |t|
    t.string   "reference_file_name"
    t.string   "reference_content_type"
    t.integer  "reference_file_size"
    t.datetime "reference_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",                  :default => true, :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_items", :force => true do |t|
    t.string   "warehouse_name",       :limit => 50
    t.integer  "stock_no_id"
    t.string   "stock_no",             :limit => 30,                                :default => "Untitled"
    t.string   "description",          :limit => 75,                                :default => "Untitled"
    t.string   "unit_of_measure",      :limit => 50,                                :default => "Each"
    t.string   "picture_path"
    t.decimal  "consignment_count",                  :precision => 15, :scale => 2
    t.integer  "high_level"
    t.integer  "low_level"
    t.decimal  "on_hand",                            :precision => 15, :scale => 2
    t.integer  "target_level"
    t.decimal  "total_count",                        :precision => 15, :scale => 2
    t.integer  "reordered_qty"
    t.datetime "requested_reorder_at"
    t.datetime "date_counted"
    t.string   "vendor_name",          :limit => 80,                                :default => "Untitled"
    t.string   "vendor_no",            :limit => 40,                                :default => "Untitled"
    t.string   "vendor_part_no",       :limit => 40,                                :default => "Untitled"
    t.boolean  "consumable",                                                        :default => false
    t.boolean  "rented",                                                            :default => false
    t.boolean  "record_weight",                                                     :default => false
    t.float    "daily_rate"
    t.float    "hourly_rate"
    t.float    "monthly_rate"
    t.float    "weekly_rate"
    t.float    "last_purchase_price"
    t.string   "aisle",                :limit => 12,                                :default => "Untitled"
    t.string   "bin",                  :limit => 12,                                :default => "Untitled"
    t.string   "shelf",                :limit => 12,                                :default => "Untitled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "building"
    t.string   "shortcut_no"
    t.boolean  "delta",                                                             :default => true,       :null => false
  end

  create_table "log_edits", :force => true do |t|
    t.integer  "loggable_id"
    t.string   "loggable_type"
    t.datetime "updated_at"
  end

  create_table "manufacturers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manufacturers_valves", :force => true do |t|
    t.integer "manufacturer_id"
    t.integer "valve_id"
    t.text    "figure_no"
  end

  create_table "material_request_attachments", :force => true do |t|
    t.integer  "material_request_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "material_requests", :force => true do |t|
    t.string   "tracking"
    t.integer  "unit_id"
    t.integer  "planner_id"
    t.string   "year"
    t.integer  "requested_by_id"
    t.datetime "date_requested"
    t.string   "telephone"
    t.date     "date_need_by"
    t.string   "work_orders"
    t.string   "deliver_to"
    t.string   "ptm_no"
    t.string   "suggested_vendor"
    t.text     "notes"
    t.integer  "authorized_by"
    t.integer  "acknowledged_by"
    t.integer  "purchaser_id"
    t.string   "stage_location"
    t.integer  "drafted_by"
    t.integer  "request_state",           :default => 0
    t.integer  "submitted_by"
    t.integer  "quote_requested_by"
    t.integer  "partially_authorized_by"
    t.integer  "declined_by"
    t.boolean  "completed",               :default => false
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "issued_from_main_by"
    t.text     "activity"
    t.boolean  "deleted",                 :default => false
    t.boolean  "surplus",                 :default => false
    t.datetime "created_at"
    t.integer  "updated_by"
    t.string   "reference_number_type"
    t.string   "reference_number"
    t.integer  "group_id"
    t.text     "description"
  end

  create_table "material_requests_orders", :id => false, :force => true do |t|
    t.integer "material_request_id"
    t.integer "order_id"
  end

  create_table "numbers", :force => true do |t|
  end

  create_table "old_manufacturers_valves", :force => true do |t|
    t.integer "manufacturer_id"
    t.integer "valve_id"
    t.text    "figure_no"
  end

  create_table "ordered_line_items", :force => true do |t|
    t.integer  "po_id"
    t.integer  "line_item_no"
    t.text     "description"
    t.integer  "quantity_ordered"
    t.integer  "quantity_received"
    t.integer  "item_price"
    t.date     "date_received"
    t.date     "date_back_ordered"
    t.text     "notes"
    t.integer  "lock_version",           :default => 0
    t.datetime "updated_at"
    t.string   "unit_of_measure"
    t.string   "details"
    t.integer  "requested_line_item_id"
    t.string   "location"
    t.date     "issued_date"
    t.string   "issued_to_name"
    t.string   "issued_to_company"
    t.integer  "issued_quantity"
    t.boolean  "delta",                  :default => true, :null => false
  end

  add_index "ordered_line_items", ["po_id", "line_item_no"], :name => "index_ordered_line_items_on_po_id_and_line_item_no"
  add_index "ordered_line_items", ["requested_line_item_id"], :name => "index_ordered_line_items_on_requested_line_item_id"

  create_table "piping_class_details", :force => true do |t|
    t.datetime "created_at"
    t.text     "description"
    t.integer  "piping_class_id"
    t.integer  "piping_component_id"
    t.integer  "section_no"
    t.string   "size_desc"
    t.datetime "updated_at"
    t.integer  "valve_id"
    t.integer  "order",                                             :default => 0
    t.decimal  "size_lower",          :precision => 6, :scale => 3
    t.decimal  "size_upper",          :precision => 6, :scale => 3
  end

  create_table "piping_classes", :force => true do |t|
    t.boolean  "archived",                 :default => false
    t.string   "class_code"
    t.text     "comments"
    t.string   "corrosion_allow"
    t.datetime "created_at"
    t.string   "flange_rating"
    t.string   "gasket_bolting"
    t.string   "gasket_material"
    t.string   "instr_spec"
    t.text     "maintenance_note"
    t.string   "max_pressure"
    t.string   "max_temp"
    t.string   "piping_material"
    t.text     "service"
    t.string   "small_fitting"
    t.text     "special_note"
    t.datetime "updated_at"
    t.string   "valve_body_material"
    t.string   "valve_trim"
    t.string   "consequence_of_failure"
    t.integer  "cross_reference_class_id"
  end

  create_table "piping_codes", :force => true do |t|
    t.string "piping_code"
  end

  create_table "piping_components", :force => true do |t|
    t.datetime "created_at"
    t.integer  "display_seq_no"
    t.string   "piping_component"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "order"
  end

  create_table "piping_material_specifications", :force => true do |t|
    t.string "piping_material_specification"
  end

  create_table "piping_materials", :force => true do |t|
    t.string "piping_material"
  end

  create_table "piping_notes", :force => true do |t|
    t.datetime "created_at"
    t.text     "note_text"
    t.datetime "updated_at"
    t.integer  "note_number"
  end

  create_table "piping_notes_piping_class_details", :id => false, :force => true do |t|
    t.integer "piping_class_detail_id"
    t.integer "piping_note_id"
  end

  add_index "piping_notes_piping_class_details", ["piping_class_detail_id", "piping_note_id"], :name => "pn_pcd_index"

  create_table "piping_reference_attachings", :force => true do |t|
    t.integer  "piping_reference_id"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "piping_reference_attachings", ["attachable_id"], :name => "index_piping_reference_attachings_on_attachable_id"
  add_index "piping_reference_attachings", ["piping_reference_id"], :name => "index_piping_reference_attachings_on_piping_reference_id"

  create_table "piping_references", :force => true do |t|
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "attachings_count",  :default => 0
    t.datetime "data_updated_at"
    t.string   "reference_type"
    t.string   "description"
    t.string   "custom_link"
    t.boolean  "show_public_link",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "piping_sizes", :force => true do |t|
    t.string  "piping_size"
    t.decimal "numerical_size", :precision => 6, :scale => 3
  end

  create_table "po_statuses", :force => true do |t|
    t.string  "status"
    t.boolean "delta",  :default => true, :null => false
    t.integer "order",  :default => 0
  end

  create_table "purchase_orders", :force => true do |t|
    t.date     "created"
    t.text     "tracking"
    t.text     "po_no"
    t.text     "description"
    t.integer  "vendor_id"
    t.integer  "status_id",                                        :default => 1
    t.string   "deliver_to"
    t.string   "work_orders"
    t.text     "ptm_no"
    t.boolean  "awr",                                              :default => false
    t.decimal  "total_cost",        :precision => 16, :scale => 2
    t.integer  "unit_id"
    t.text     "turnaround_year"
    t.date     "date_eta"
    t.boolean  "completed",                                        :default => false
    t.boolean  "closed",                                           :default => false
    t.text     "location"
    t.text     "activity"
    t.text     "issued_to_history"
    t.integer  "lock_version",                                     :default => 0
    t.datetime "updated_at"
    t.integer  "record_counter"
    t.integer  "planner_id"
    t.integer  "requested_by_id"
    t.date     "date_need_by"
    t.date     "date_requested"
    t.boolean  "stage"
    t.string   "suggested_vendor"
    t.boolean  "acknowledged",                                     :default => false
    t.boolean  "authorized",                                       :default => false
    t.boolean  "archived",                                         :default => false
    t.integer  "group_id"
    t.boolean  "delta",                                            :default => true,  :null => false
  end

  add_index "purchase_orders", ["created"], :name => "index_purchase_orders_on_created"

  create_table "quote_attachments", :force => true do |t|
    t.integer  "quote_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "quote_items", :force => true do |t|
    t.integer  "requested_line_item_id"
    t.integer  "item_no"
    t.integer  "quote_id"
    t.integer  "quantity"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "price"
    t.date     "date_available"
    t.string   "unit_of_measure"
    t.string   "vendor_part_number"
  end

  create_table "quotes", :force => true do |t|
    t.integer  "material_request_id"
    t.integer  "vendor_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "discussion"
    t.datetime "discussion_updated_at"
    t.boolean  "discussion_flag"
    t.integer  "acknowledged_by"
    t.integer  "emailed_by"
    t.boolean  "delta",                 :default => true, :null => false
  end

  create_table "recent_date_range", :id => false, :force => true do |t|
    t.integer "id",                   :default => 0, :null => false
    t.date    "date"
    t.string  "dayname", :limit => 9
  end

  create_table "record_changelogs", :force => true do |t|
    t.string   "record_type"
    t.string   "field_name"
    t.text     "old_value"
    t.text     "new_value"
    t.datetime "modified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "record_identifier"
    t.string   "action"
    t.string   "modified_by"
    t.text     "comment"
    t.integer  "record_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "reference_number_types", :force => true do |t|
    t.string   "name"
    t.integer  "order_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.boolean  "default",      :default => false
  end

  create_table "reminders", :force => true do |t|
    t.integer  "po_id"
    t.text     "email_to"
    t.date     "send_reminder_on"
    t.text     "notes"
    t.integer  "created_by"
    t.datetime "sent_on"
    t.datetime "updated_at"
  end

  add_index "reminders", ["po_id"], :name => "index_reminders_on_po_id"

  create_table "requested_line_items", :force => true do |t|
    t.integer "item_no"
    t.integer "quantity"
    t.string  "unit_of_measure"
    t.text    "material_description"
    t.string  "notes"
    t.integer "material_request_id"
  end

  add_index "requested_line_items", ["material_request_id"], :name => "index_requested_line_items_on_material_request_id"

  create_table "resource_permissions", :force => true do |t|
    t.string   "name"
    t.boolean  "enabled",    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer "taggable_id"
    t.integer "tag_id"
    t.string  "taggable_type"
  end

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "temporary_piping_class_dtls", :id => false, :force => true do |t|
    t.string   "Class_Code"
    t.string   "Section_No"
    t.string   "Piping_Comp_Name"
    t.string   "Line_No"
    t.string   "Size_Desc"
    t.string   "Description"
    t.string   "Valve_No"
    t.string   "Note_No"
    t.string   "Note_No1"
    t.string   "Note_No2"
    t.string   "Note_No3"
    t.string   "Note_No4"
    t.string   "Last_Updt_Id"
    t.datetime "Last_Updt_date"
  end

  create_table "tickets", :force => true do |t|
    t.integer  "number"
    t.string   "title"
    t.text     "body"
    t.string   "category"
    t.string   "state"
    t.string   "priority"
    t.string   "context"
    t.string   "assigned_to"
    t.string   "reported_by"
    t.text     "response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "unit_for_measures", :force => true do |t|
    t.string "name"
    t.string "description"
  end

  create_table "unit_of_measures", :force => true do |t|
    t.string "unit_of_measure"
  end

  create_table "units", :force => true do |t|
    t.string   "description",  :limit => 80
    t.integer  "lock_version",               :default => 0
    t.datetime "updated_at"
    t.datetime "created_at"
    t.string   "unit_no"
    t.boolean  "delta",                      :default => true, :null => false
  end

  create_table "user_notes", :force => true do |t|
    t.string   "table_type"
    t.string   "table_id"
    t.string   "table_field_name"
    t.string   "table_field_data"
    t.text     "note"
    t.integer  "submitted_by"
    t.integer  "reviewed_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.boolean  "hidden",                  :default => false, :null => false
    t.string   "original_resource_name"
    t.string   "original_resource_title"
    t.string   "reason"
  end

  create_table "valve_components", :force => true do |t|
    t.string   "component_name"
    t.datetime "created_at"
    t.integer  "display_seq_no"
    t.datetime "updated_at"
    t.integer  "order_numbering"
  end

  create_table "valves", :force => true do |t|
    t.datetime "created_at"
    t.boolean  "discontinued"
    t.string   "manufacturers_remarks"
    t.datetime "updated_at"
    t.string   "valve_code"
    t.text     "valve_note"
    t.boolean  "archived",              :default => false
    t.text     "valve_body"
    t.text     "valve_rating"
    t.text     "valve_type"
    t.text     "comments"
  end

  create_table "valves_valve_components", :force => true do |t|
    t.text    "component_text"
    t.integer "valve_component_id"
    t.integer "valve_id"
  end

  add_index "valves_valve_components", ["valve_id", "valve_component_id"], :name => "index_valves_valve_components_on_valve_id_and_valve_component_id"

  create_table "vendor_bill_items", :force => true do |t|
    t.integer "bill_id"
    t.integer "bill_item_id"
    t.integer "vendor_id"
    t.text    "notes"
    t.string  "price"
    t.date    "availability"
  end

  create_table "vendor_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vendor_groups_vendors", :id => false, :force => true do |t|
    t.integer "vendor_id"
    t.integer "vendor_group_id"
  end

  create_table "vendors", :force => true do |t|
    t.string   "vendor_no"
    t.string   "name"
    t.string   "email"
    t.string   "account_no"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "telephone"
    t.string   "fax"
    t.string   "contact_name"
    t.string   "contact_telephone"
    t.text     "notes"
    t.integer  "lock_version",      :default => 0
    t.datetime "updated_at"
    t.string   "access_key"
    t.boolean  "delta",             :default => true, :null => false
  end

  create_table "virtual_badges", :force => true do |t|
    t.integer  "virtual_badge_no"
    t.integer  "physical_badge_facility_code"
    t.integer  "physical_badge_id"
    t.integer  "lock_version",                 :default => 0
    t.datetime "updated_at"
  end

end
