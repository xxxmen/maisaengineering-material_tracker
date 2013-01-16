# == Schema Information
# Schema version: 20090730175917
#
# Table name: piping_sizes
#
#  id             :integer(4)    not null, primary key
#  piping_size    :string(255)   
#  numerical_size :decimal(6, 3) 
#

class PipingSize < ActiveRecord::Base
	
end
