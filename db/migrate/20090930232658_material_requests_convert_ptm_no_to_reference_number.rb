class MaterialRequestsConvertPtmNoToReferenceNumber < ActiveRecord::Migration
  	def self.up
  		MaterialRequest.all.each do |m|
  			m.reference_number_type = 'Process/Ticket/MES'
  			m.reference_number = m.ptm_no
  			
  			puts "MR #{m.id}: #{m.reference_number_type} (#{m.ptm_no}/#{m.reference_number})"
  			m.save(false)
 		end
  	end

  	def self.down
  	end
end
