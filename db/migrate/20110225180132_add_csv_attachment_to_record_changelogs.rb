class AddCsvAttachmentToRecordChangelogs < ActiveRecord::Migration
  def self.up
  	add_column :record_changelogs, :attachment_file_name, :string
    add_column :record_changelogs, :attachment_content_type, :string
    add_column :record_changelogs, :attachment_file_size, :integer
    add_column :record_changelogs, :attachment_updated_at, :datetime
  end

  def self.down
  end
end
