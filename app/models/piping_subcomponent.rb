# == Schema Information
# Schema version: 102
#
# Table name: piping_subcomponents
#
#  id                  :integer(11)   not null, primary key
#  piping_component_id :integer(11)   
#  description         :text          
#


class PipingSubcomponent < ActiveRecord::Base
  belongs_to :piping_component
  
end
