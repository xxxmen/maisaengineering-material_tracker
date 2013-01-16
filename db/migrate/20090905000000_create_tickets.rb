class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.integer :number
      t.string :title
      t.text 	:body
      t.string 	:category
      t.string 	:state
      t.string 	:priority
      t.string 	:context
      t.string 	:assigned_to
      t.string 	:reported_by
      t.text	:response
      t.timestamps
    end
  end

  def self.down
    drop_table :tickets
  end
end
