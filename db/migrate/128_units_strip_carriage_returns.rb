class UnitsStripCarriageReturns < ActiveRecord::Migration
  def self.up
    execute("UPDATE units SET unit_no = TRIM('\r' FROM unit_no)")
  end

  def self.down
  end
end
