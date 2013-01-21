class MigrateBillReferenceNumbersToNewFields < ActiveRecord::Migration
  	def self.up
  		Bill.record_timestamps = false
  		
  		@bills = Bill.find(:all)
  		@bills.each do |bill|
  			bill.reference_number_1_type = 'Process'
  			bill.reference_number_1 = bill.process
  			
  			bill.reference_number_2_type = 'Ticket'
  			bill.reference_number_2 = bill.ticket
  			
  			bill.reference_number_3_type = 'MES'  			
  			bill.reference_number_3 = bill.mes

  			bill.save(false)
 		end
 		
  		Bill.record_timestamps = true
  	end

  	def self.down
  		Bill.record_timestamps = false
  		
  		@bills = Bill.find(:all)
  		@bills.each do |bill|  			
  			[1,2,3].each do |num|
  				type = bill.send("reference_number_#{num}_type")
  				value = bill.send("reference_number_#{num}")
  				
	  			if type == 'Process'
		  			bill.process = value
	  			elsif type == 'Ticket'
		  			bill.ticket = value
  				elsif type == 'MES'
		  			bill.mes = value
	  			end	  			
 			end
  			
  			bill.save(false)
 		end
 		
  		Bill.record_timestamps = true 		
  	end
end
