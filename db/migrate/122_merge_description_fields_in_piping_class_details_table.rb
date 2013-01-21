class MergeDescriptionFieldsInPipingClassDetailsTable < ActiveRecord::Migration
    # Merges all description_detail fields into description and removes the
    # description_detail column.
    def self.up
        details = PipingClassDetail.find(:all)
        details.each do |detail|
            if !(detail.description_detail.blank?)
                detail.description += " -- " + detail.description_detail
                detail.save!
            end
        end
        
        remove_column :piping_class_details, :description_detail
    end

    def self.down
        add_column :piping_class_details, :description_detail, :text
    end
end
