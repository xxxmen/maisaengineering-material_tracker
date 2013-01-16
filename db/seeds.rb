

# Using the gem factory_girl to generate seed data for development
# Site: http://github.com/thoughtbot/factory_girl

puts "** ** Loading Seed Data... ** **"

#we can use this to find a random item for the given account
#this assumes the account_id exists in the instance model
def find_random(model, instance=nil)
	#if the instance isn't specified, don't scope by account_id
	if(instance.nil?)
		return model.find(:first, :offset => rand(model.count()))
	else
		return model.find(:first, {:conditions => "account_id = #{instance.account_id}",
						:offset => rand(model.count(:conditions => "account_id = #{instance.account_id}"))})
	end
end
@no_output = false

Dir.glob(File.join(File.expand_path(RAILS_ROOT), "db", "factories", "*.rb")).each do |factory|
  require factory
end
puts "Factories Loaded"

PoStatus.create_defaults

Unit.create(:description => "Default Job Site")

c = Company.create(:name => ENV['DEPLOY_SITE_NAME'])
puts "Sample Company: '#{ENV['DEPLOY_SITE_NAME']}'Created"

g= Group.create(:name => 'Default')

e = Employee.create(:first_name => 'Admin',
								:last_name => 'Admin',
								:login => 'admin',
								:group => g,
								:password => 'admin', :password_confirmation => 'admin',
								:role => 'Admin',
								:start_page => 'Menu',
								:company => c)

UnitForMeasure.create(:name =>"YD",:description =>"Yard")
UnitForMeasure.create(:name =>"OZ",:description =>"Ounce - Av")
UnitForMeasure.create(:name =>"LB",:description =>"Pound")
UnitForMeasure.create(:name =>"HH",:description =>"Hundred Cubic F")
UnitForMeasure.create(:name =>"GR",:description =>"Gram")
UnitForMeasure.create(:name =>"DZ",:description =>"Dozen")
UnitForMeasure.create(:name =>"DO",:description =>"Dollars, U.S.")
UnitForMeasure.create(:name =>"CN",:description =>"Can")
UnitForMeasure.create(:name =>"BX",:description =>"Box")
UnitForMeasure.create(:name =>"ST",:description =>"Set")
UnitForMeasure.create(:name =>"GS",:description =>"Gross")
UnitForMeasure.create(:name =>"PR",:description =>"Pair")
UnitForMeasure.create(:name =>"PH",:description =>"Pack (PAK)")
UnitForMeasure.create(:name =>"MO",:description =>"Months")
UnitForMeasure.create(:name =>"LY",:description =>"Linear Yard")
UnitForMeasure.create(:name =>"BO",:description =>"Bottle")
UnitForMeasure.create(:name =>"UN",:description =>"Unit")
UnitForMeasure.create(:name =>"TB",:description =>"Tube")
UnitForMeasure.create(:name =>"QT",:description =>"Quart")
UnitForMeasure.create(:name =>"MP",:description =>"Metric Ton")
UnitForMeasure.create(:name =>"LO",:description =>"Lot")
UnitForMeasure.create(:name =>"FT",:description =>"Foot")
UnitForMeasure.create(:name =>"DR",:description =>"Drum")
UnitForMeasure.create(:name =>"CF",:description =>"Cubic Foot")
UnitForMeasure.create(:name =>"TN",:description =>"Net Ton (2,000)")
UnitForMeasure.create(:name =>"RL",:description =>"Roll")
UnitForMeasure.create(:name =>"PT",:description =>"Pint")
UnitForMeasure.create(:name =>"LF",:description =>"Linear Foot")
UnitForMeasure.create(:name =>"GA",:description =>"Gallon")
UnitForMeasure.create(:name =>"BF",:description =>"Board Feet")
UnitForMeasure.create(:name =>"TO",:description =>"Troy Ounce")
UnitForMeasure.create(:name =>"RM",:description =>"Ream")
UnitForMeasure.create(:name =>"PK",:description =>"Package")
UnitForMeasure.create(:name =>"MR",:description =>"Meter")
UnitForMeasure.create(:name =>"IN",:description =>"Inch")
UnitForMeasure.create(:name =>"HC",:description =>"Hundred Count")
UnitForMeasure.create(:name =>"BR",:description =>"Barrel")
UnitForMeasure.create(:name =>"BG",:description =>"Bag")
UnitForMeasure.create(:name =>"SY",:description =>"Square Yard")
UnitForMeasure.create(:name =>"KG",:description =>"Kilogram")
UnitForMeasure.create(:name =>"EA",:description =>"Each")
UnitForMeasure.create(:name =>"CT",:description =>"Carton")
UnitForMeasure.create(:name =>"DA",:description =>"Days")
UnitForMeasure.create(:name =>"SF",:description =>"Square Foot")
UnitForMeasure.create(:name =>"RE",:description =>"Reel")
UnitForMeasure.create(:name =>"LT",:description =>"Liter")
UnitForMeasure.create(:name =>"CA",:description =>"Case")
UnitForMeasure.create(:name =>"TH",:description =>"Thousand")
UnitForMeasure.create(:name =>"PD",:description =>"Pad")
UnitForMeasure.create(:name =>"ML",:description =>"Milliliter")
UnitForMeasure.create(:name =>"KT",:description =>"Kit")
UnitForMeasure.create(:name =>"SH",:description =>"Sheet")
UnitForMeasure.create(:name =>"HR",:description =>"Hours")


#UnitOfMeasure.create(:name => "box")
#UnitOfMeasure.create("case")
#UnitOfMeasure.create("ea")
#UnitOfMeasure.create("feet")
#UnitOfMeasure.create("gallon")
#UnitOfMeasure.create("lbs")
#UnitOfMeasure.create("lot")
#UnitOfMeasure.create("package")
#UnitOfMeasure.create("roll")
#enable all resources except POPV
ResourcePermission.initialize_resources(true)

puts "Enable ALL Resources"
ResourcePermission.enable_all()
puts ""
puts "Disable POPV"

ResourcePermission.disable(:popv)

#


puts "Populated Telaeris Locations" unless @no_output

