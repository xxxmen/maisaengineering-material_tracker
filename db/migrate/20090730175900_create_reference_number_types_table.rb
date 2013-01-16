class CreateReferenceNumberTypesTable < ActiveRecord::Migration
  	def self.up
		create_table :reference_number_types, :force => true do |t|
			t.string	:name
			t.integer	:order_number
			t.datetime	:created_at
			t.datetime	:updated_at
			t.integer	:created_by
			t.integer	:updated_by
		end
		
		puts "== Starting creation of ReferenceNumberTypes... =================="
		['Process', 'Ticket', 'MES', 'Process/Ticket/MES'].each_with_index do |type, index|
			reference = ReferenceNumberType.create(:name => type, :order_number => index)
			puts "Created ReferenceNumberType: #{reference.inspect}"
		end
		puts "== Finished creation of ReferenceNumberTypes! ===================="
  	end

  	def self.down
  		drop_table :reference_number_types
  	end
end
