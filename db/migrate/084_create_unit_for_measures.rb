# Used to autofill the 'units' field for requested line items
UNITS_FOR_MEASURE = {
  "BF" => "Board Feet",
  "BG" => "Bag",
  "BO" => "Bottle",
  "BR" => "Barrel",
  "BX" => "Box",
  "CA" => "Case",
  "CF" => "Cubic Foot",
  "CN" => "Can",
  "CT" => "Carton",
  "DA" => "Days",
  "DO" => "Dollars, U.S.",
  "DR" => "Drum",
  "DZ" => "Dozen",
  "EA" => "Each",
  "FT" => "Foot",
  "GA" => "Gallon",
  "GR" => "Gram",
  "GS" => "Gross",
  "HC" => "Hundred Count",
  "HH" => "Hundred Cubic F",
  "HR" => "Hours",
  "IN" => "Inch",
  "KG" => "Kilogram",
  "KT" => "Kit",
  "LB" => "Pound",
  "LF" => "Linear Foot",
  "LO" => "Lot",
  "LT" => "Liter",
  "LY" => "Linear Yard",
  "ML" => "Milliliter",
  "MO" => "Months",
  "MP" => "Metric Ton",
  "MR" => "Meter",
  "OZ" => "Ounce - Av",
  "PD" => "Pad",
  "PH" => "Pack (PAK)",
  "PK" => "Package",
  "PR" => "Pair",
  "PT" => "Pint",
  "QT" => "Quart",
  "RE" => "Reel",
  "RL" => "Roll",
  "RM" => "Ream",
  "SF" => "Square Foot",
  "SH" => "Sheet",
  "ST" => "Set",
  "SY" => "Square Yard",
  "TB" => "Tube",
  "TH" => "Thousand",
  "TN" => "Net Ton (2,000)",
  "TO" => "Troy Ounce",
  "UN" => "Unit",
  "YD" => "Yard"
}

class CreateUnitForMeasures < ActiveRecord::Migration
  def self.up
    create_table :unit_for_measures do |t|
      t.string "name", "description"
    end
    
    UNITS_FOR_MEASURE.each do |name, description|
      UnitForMeasure.create!(:name => name, :description => description)
    end
  end

  def self.down
    drop_table :unit_for_measures
  end
end
