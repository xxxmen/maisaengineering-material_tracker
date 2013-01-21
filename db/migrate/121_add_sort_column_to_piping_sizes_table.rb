class AddSortColumnToPipingSizesTable < ActiveRecord::Migration
    def self.up
        add_column :piping_sizes, :numerical_size, :decimal, :precision => 6, :scale => 3
        sizes = [
            ["1/8\"", 0.125], 
            ["1/4\"", 0.25], 
            ["3/8\"", 0.375], 
            ["1/2\"", 0.5], 
            ["3/4\"", 0.75], 
            ["1\"", 1], 
            ["1 1/4\"", 1.25], 
            ["1 1/2\"", 1.5], 
            ["2\"", 2], 
            ["2 1/2\"", 2.5], 
            ["3\"", 3], 
            ["3 1/2\"", 3.5], 
            ["4\"", 4], 
            ["5\"", 5], 
            ["6\"", 6], 
            ["8\"", 8], 
            ["10\"", 10], 
            ["12\"", 12], 
            ["14\"", 14], 
            ["16\"", 16], 
            ["18\"", 18], 
            ["20\"", 20], 
            ["24\"", 24], 
            ["26\"", 26], 
            ["30\"", 30], 
            ["36\"", 36], 
            ["48\"", 48], 
            ["54\"", 54]
        ]
        
        PipingSize.delete_all
        sizes.each do |size|
            piping_size = size[0]
            numerical_size = size[1]
            PipingSize.create(:piping_size => piping_size, :numerical_size => numerical_size)
        end
    end

    def self.down
        remove_column :piping_sizes, :numerical_size
    end
end



