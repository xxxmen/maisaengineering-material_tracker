class ModifyDataForNewSchema < ActiveRecord::Migration
  def self.up
    MaterialRequest.find(:all).each do |request|
      request.submitted_by = request.requested_by_id
      request.save
    end
  end

  def self.down
  end
end
