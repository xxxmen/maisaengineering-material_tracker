class Number < ActiveRecord::Base
end


class CreateNumbers < ActiveRecord::Migration
  def self.up
    create_table "numbers" do |t|
    end
    
    
    # create 30 static numbers in the database (1-30) for reports
    31.times do |number|
      n = Number.new
      n.id = number
      n.save
    end
  end

  def self.down
    drop_table "numbers"
  end
end
