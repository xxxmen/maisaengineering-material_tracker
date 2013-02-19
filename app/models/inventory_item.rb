# == Schema Information
# Schema version: 20090730175917
#
# Table name: inventory_items
#
#  id                   :integer(4)    not null, primary key
#  warehouse_name       :string(50)    
#  stock_no_id          :integer(4)    
#  stock_no             :string(30)    default("Untitled")
#  description          :string(75)    default("Untitled")
#  unit_of_measure      :string(50)    default("Each")
#  picture_path         :string(255)   
#  consignment_count    :decimal(15, 2 
#  high_level           :integer(10)   
#  low_level            :integer(10)   
#  on_hand              :decimal(15, 2 
#  target_level         :integer(10)   
#  total_count          :decimal(15, 2 
#  reordered_qty        :integer(10)   
#  requested_reorder_at :datetime      
#  date_counted         :datetime      
#  vendor_name          :string(80)    default("Untitled")
#  vendor_no            :string(40)    default("Untitled")
#  vendor_part_no       :string(40)    default("Untitled")
#  consumable           :boolean(1)    
#  rented               :boolean(1)    
#  record_weight        :boolean(1)    
#  daily_rate           :float         
#  hourly_rate          :float         
#  monthly_rate         :float         
#  weekly_rate          :float         
#  last_purchase_price  :float         
#  aisle                :string(12)    default("Untitled")
#  bin                  :string(12)    default("Untitled")
#  shelf                :string(12)    default("Untitled")
#  created_at           :datetime      
#  updated_at           :datetime      
#  building             :string(255)   
#  shortcut_no          :string(255)   
#

class InventoryItem < ActiveRecord::Base

  # Using ThinkingSphinx now... (Adam - 2009-06-18)
  #  acts_as_ferret :fields => [
  #  	:warehouse_name,
  #  	:stock_no_id,
  #  	:stock_no,
  #  	:description,
  #  	:unit_of_measure,
  #  	:vendor_name,
  #  	:vendor_no,
  #  	:vendor_part_no,
  #  	:building,
  #  	:tag_terms
  #  ]

  acts_as_taggable

  extend Listable::ModelHelper

  # Thinking Sphinx Config
  define_index do
    indexes :warehouse_name
    # indexes :stock_no_id
    indexes :stock_no
    indexes :description
    indexes :unit_of_measure
    indexes :vendor_name
    indexes :vendor_no
    indexes :vendor_part_no
    indexes :building
    set_property :delta => true
  end

  PERPAGE = 100

  validates_presence_of :description, :stock_no_id, :warehouse_name, :allow_blank => false

  def self.all_vendor_names
    vendor_names = InventoryItem.find(:all, :select => "distinct(vendor_name)", :order => "vendor_name").map(&:vendor_name)
  end

  def self.merge_update(attrs)
    item = InventoryItem.find(:first, :conditions => { :warehouse_name=> attrs['warehouse_name'], :stock_no_id => attrs['stock_no_id'] })
    if item # update record
      item.update_attributes!(attrs)
    else #create record
      item = self.create!(attrs)
    end

    return item
  end

  def self.filter(params)
    if params[:vendor_name]
      self.with_scope(:find => {:conditions => {:vendor_name => params[:vendor_name] }}) { yield }
    else
      yield
    end
  end

  def quantity_available
    if self.consignment_count && self.on_hand
      return self.consignment_count + self.on_hand
    elsif self.consignment_count
      return self.consignment_count
    elsif self.on_hand
      return self.on_hand
    else
      return 0
    end
  end

  def tag_terms
    self.tags.map(&:name).join(" ")
  end

  def self.select_vendor_names(reorder = false)
    if reorder
      where_clause = "(consignment_count + total_count) <= low_level AND low_level > 0 AND requested_reorder_at IS NULL"
    else
      where_clause = "1=1"
    end

    vendor_names = InventoryItem.find(:all, :select => "distinct(vendor_name)", :order => "vendor_name", :conditions => where_clause).map do |i|
      i.vendor_name ? [i.vendor_name.upcase, i.vendor_name.upcase] : ["UNSPECIFIED", "UNSPECIFIED"]
    end.unshift(["ALL", ""])
  end


  # ===============
  # = CSV support =
  # ===============
  comma do
    InventoryItem.column_names.each do |column_name|
      case column_name
        when 'delta'
          #skip
        else
          send(column_name,column_name.underscore)
      end
    end
  end


end
