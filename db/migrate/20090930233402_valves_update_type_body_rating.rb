class ValvesUpdateTypeBodyRating < ActiveRecord::Migration
	def self.up
		RecordChangelog.enable_recording = false
		
		Valve.find(:all, :include => {:valves_valve_components => [:valve_component] }).each do |valve|
			puts "Migrating Valve: #{valve.valve_code}"
			valve.valves_valve_components.each do |vvc|
				next if vvc.valve_component.blank?
				
				name = vvc.valve_component.component_name
				
				next if name.blank?
				
				text = vvc.component_text
					
				if name == 'TYPE'
					valve.valve_type = text
					vvc.destroy
				elsif name == 'BODY'
					valve.valve_body = text
					vvc.destroy
				elsif name == 'RATING'
					valve.valve_rating = text
					vvc.destroy
				end
			end
			valve.save!
		end
		
		RecordChangelog.enable_recording = true
	end

	def self.down
	end
end
