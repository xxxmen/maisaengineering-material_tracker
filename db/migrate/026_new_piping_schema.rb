# Auto Generated Migration File : 9/5/2007 3:53:52 PM
class NewPipingSchema < ActiveRecord::Migration
  def self.up
    # Clear out the old piping schema
    drop_table :piping_classes
    drop_table :piping_components
    
    create_table :general_notes do |t| 
      t.column :created_at,	:datetime
      t.column :section_name,	:string
      t.column :section_no,	:integer
      t.column :section_text,	:string
      t.column :updated_at,	:datetime
    end 
    create_table :manufacturers do |t| 
      t.column :alt_phone_no,	:string
      t.column :city,	:string
      t.column :contact_name,	:string
      t.column :created_at,	:datetime
      t.column :manufacturer_name,	:string
      t.column :phone_no,	:string
      t.column :state,	:string
      t.column :street,	:string
      t.column :updated_at,	:datetime
      t.column :zip,	:string
    end 
    create_table :manufacturers_valves do |t| 
      t.column :figure_no,	:string
      t.column :manufacturer_id,	:decimal
      t.column :valve_id,	:decimal
    end 
    create_table :piping_class_details do |t| 
      t.column :created_at,	:datetime
      t.column :description,	:string
      t.column :piping_class_id,	:decimal
      t.column :piping_component_id,	:decimal
      t.column :section_no,	:decimal
      t.column :size_desc,	:string
      t.column :updated_at,	:datetime
      t.column :valve_id,	:decimal
    end 
    create_table :piping_classes do |t| 
      t.column :archived,	:boolean
      t.column :class_code,	:string
      t.column :comments,	:string
      t.column :corrosion_allow,	:string
      t.column :created_at,	:datetime
      t.column :flange_rating,	:string
      t.column :gasket_bolting,	:string
      t.column :gasket_material,	:string
      t.column :instr_spec,	:string
      t.column :maintenance_note,	:string
      t.column :max_pressure,	:string
      t.column :max_temp,	:string
      t.column :piping_material,	:string
      t.column :service,	:string
      t.column :small_fitting,	:string
      t.column :special_note,	:string
      t.column :updated_at,	:datetime
      t.column :valve_body_material,	:string
      t.column :valve_trim,	:string
    end 
    create_table :piping_components do |t| 
      t.column :created_at,	:datetime
      t.column :display_seq_no,	:integer
      t.column :piping_component,	:string
      t.column :updated_at,	:datetime
    end 
    create_table :piping_notes do |t| 
      t.column :created_at,	:datetime
      t.column :note_text,	:string
      t.column :updated_at,	:datetime
    end 
    create_table :piping_notes_piping_class_details do |t| 
      t.column :piping_class_detail_id,	:decimal
      t.column :piping_class_note_id,	:decimal
    end 
    create_table :valve_components do |t| 
      t.column :component_name,	:string
      t.column :created_at,	:datetime
      t.column :display_seq_no,	:integer
      t.column :updated_at,	:datetime
    end 
    create_table :valve_details do |t| 
      t.column :component_name,	:string
      t.column :component_text,	:string
      t.column :created_at,	:datetime
      t.column :updated_at,	:datetime
      t.column :valve_id,	:decimal
    end 
    create_table :valves do |t| 
      t.column :created_at,	:datetime
      t.column :discontinued,	:boolean
      t.column :manufacturers_remarks,	:string
      t.column :updated_at,	:datetime
      t.column :valve_code,	:string
      t.column :valve_note,	:string
    end 
    create_table :valves_valve_components do |t| 
      t.column :component_text,	:string
      t.column :valve_component_id,	:decimal
      t.column :valve_id,	:decimal
    end 
  end

  def self.down
      drop_table  :general_notes
      drop_table  :manufacturers
      drop_table  :manufacturers_valves
      drop_table  :piping_class_details
      drop_table  :piping_classes
      drop_table  :piping_components
      drop_table  :piping_notes
      drop_table  :piping_notes_piping_class_details
      drop_table  :valve_components
      drop_table  :valve_details
      drop_table  :valves
      drop_table  :valves_valve_components
  end

end
