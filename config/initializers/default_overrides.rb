
MAIL_TEST_EMAIL = 'no-reply@sukedharreddy.info'
#MAIL_TEST_EMAIL = 'errors@telaeris.com'

class Array
  def to_csv(options = {})
    # If the array is filled with AR objects, parse its attributes
    if self.length == 0
      ""
    elsif all? { |e| e.respond_to?(:to_row) }
      header_row = first.class.column_names.to_csv
      content_rows = map { |e| e.to_row }.map { |r| r.to_csv }
      ([header_row] + content_rows).join
    else
      CSV.generate_line(self, options)
    end
  end
end

# Temporary fix for paperclip. See:
# https://thoughtbot.lighthouseapp.com/projects/8794-paperclip/tickets/158-clearing-an-attachment-from-a-new-record-throws-an-error-upon-save
#
#module Paperclip
#  # The Attachment class manages the files for a given attachment. It saves
#  # when the model saves, deletes when the model is destroyed, and processes
#  # the file upon assignment.
#  class Attachment
#    def clear
#      queue_existing_for_delete
#      @queued_for_write  = {}
#      @errors            = {}
#      @validation_errors = nil
#    end
#  end
#end


class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end

if "irb" == $0
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end


#class Hash
#    def has?(*args)
#      current = self
#      args.each do |arg|
#        if current.has_key?(arg)
#          current = current[arg]
#        else
#          current = nil
#          break
#        end
#      end
#
#      return current
#    end
#end