# == Schema Information
# Schema version: 20090730175917
#
# Table name: log_edits
#
#  id            :integer(4)    not null, primary key
#  loggable_id   :integer(4)    
#  loggable_type :string(255)   
#  updated_at    :datetime      
#

class LogEdit < ActiveRecord::Base
  belongs_to :loggable, :polymorphic => true
end
