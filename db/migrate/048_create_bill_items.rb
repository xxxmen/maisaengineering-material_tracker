class CreateBillItems < ActiveRecord::Migration
  def self.up
    create_table :bill_items do |t|
      t.integer  :bill_id, :quantity, :pipe_class_id, :pipe_comp_id, 
                 :pipe_subcomp_id, :pipe_class_details_id, :size_1_id, :size_2_id, :item_no
      t.string   :unit_of_measure
      t.text     :description, :notes
      t.boolean  :manual, :default => false
      t.timestamps 
    end
  end

  def self.down
    drop_table :bill_items
  end
end
