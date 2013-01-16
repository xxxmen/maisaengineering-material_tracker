# == Schema Information
# Schema version: 20090730175917
#
# Table name: piping_class_details
#
#  id                  :integer(4)    not null, primary key
#  created_at          :datetime
#  description         :text
#  piping_class_id     :integer(10)
#  piping_component_id :integer(10)
#  section_no          :integer(10)
#  size_desc           :string(255)
#  updated_at          :datetime
#  valve_id            :integer(10)
#

class PipingClassDetail < ActiveRecord::Base
  ############################################################################
  # MIXINS
     ############################################################################
  # Added to include helper methods for dealing with polymorphic piping_references.
    include PipingReferenceHelper

  ############################################################################
  # ASSOCIATIONS
     ############################################################################

  belongs_to :piping_class
    belongs_to :piping_component
    belongs_to :valve
    has_and_belongs_to_many :piping_notes, :join_table => :piping_notes_piping_class_details
    has_many :user_notes, :as => :table

    has_many :piping_reference_attachings, :as => :attachable, :dependent => :destroy
    has_many :piping_references, :through => :piping_reference_attachings
    #acts_as_polymorphic_paperclip
    attr_accessor :subcomponent_ids

     ############################################################################
  # CONSTANTS
     ############################################################################

    PAGE_LIMIT = 400
    PERPAGE = 400
    SEXT_INCLUDE = [:piping_class, :piping_component, :valve, :piping_notes, :user_notes, :piping_references]
    PAGE_ORDER_MAPPING = {
      :valve => "valves.valve_code",
      :piping_component => 'piping_components.piping_component',
      :piping_notes => 'piping_notes.note_number'
    }
    SEXT_SEARCH_FIELDS = ["valves.valve_code",'piping_components.piping_component', 'piping_class_details.description', 'piping_class_details.size_desc']

  ############################################################################
  # VALIDATIONS
     ############################################################################

    validates_presence_of :piping_class_id,
                :piping_component_id,
                :size_desc,
                :description


  ############################################################################
  # CALLBACKS
    ############################################################################

    before_create { |record|
      if(!record.subcomponent_ids.blank?)
         ids = record.subcomponent_ids.split(',')
         ids.each do |this_id|
           attributes = record.attributes
           attributes['piping_component_id'] = this_id
           
           PipingClassDetail.create!(attributes)
         end

      end
    }
    #the order for a detail should be the same as the highest order of a similar detail.(same piping_class_id/piping_component_id)
    before_create { |record|
      class_conditions = "piping_class_id = #{record.piping_class_id}"
      if(record.piping_component.parent_id.blank?)
        component_conditions = "piping_components.id = #{record.piping_component_id}"
      else
        component_conditions = "piping_components.id = #{record.piping_component.parent_id}"
      end

      highest_order = PipingClassDetail.find(:first,
        :include => [:piping_component => :parent_component],
        :order => " (CASE WHEN (piping_components.parent_id IS NULL) THEN (piping_components.piping_component) 
                      ELSE (parent_components_piping_components.piping_component) END)",
        :conditions => "#{class_conditions} AND #{component_conditions}")

        value_highest_order = 0
        if(highest_order.nil?)
           value_highest_order = 1
        else
            value_highest_order = highest_order.order
        end
        #this could be done with a SQL statement.
        #PipingClassDetail.update_all(updates, conditions = nil)
        PipingClassDetail.update_all("piping_class_details.order = piping_class_details.order - 1", class_conditions + " AND piping_class_details.order <= #{value_highest_order}")
        PipingClassDetail.update_all("piping_class_details.order = piping_class_details.order + 1", class_conditions + " AND piping_class_details.order >= #{value_highest_order}")
        record.order = value_highest_order
      }


    # Logs any field changes (not creates or deletes, though...)
    before_update { |record|
      RecordChangelog.record_changes(record, {:record_type => 'PipingDetail'})
    }
    after_create { |record| RecordChangelog.record_creation(record, {:record_type => 'PipingDetail'}) }
    after_destroy { |record| RecordChangelog.record_deletion(record, {:record_type => 'PipingDetail'}) }

    #before we create a detail we need to give its record an order.  Before we give an order we should
  ############################################################################
  # INSTANCE METHODS
     ############################################################################

  # For use by RecordChangelog
  def record_changelog_identifier
    piping_component = self.piping_component ? self.piping_component.piping_component : "No Component: PipingComponentID=#{self.piping_component_id}"
    "#{self.piping_class.class_code} - #{piping_component} - #{self.description}"
  end

  def piping_notes=(notes)
  #  if(notes.blank?)
  #    logger.error "PIPING CLASS DETAIL NOTES ARE BLANK"
  #  else
      logger.error "PIPING CLASS DETAIL NOTES(class: #{notes.class}): #{notes.to_yaml} "
      note_array = notes.split(',')
      #wrap it all in a transaction in case any part fails.
      transaction {
        #clear our our current notes for this item.
        self.piping_notes.clear
        #look up each note in the array  and add to our collection
        note_array.each do |note_number|
          self.piping_notes << PipingNote.find_by_note_number(note_number)
        end
      }
  #  end
  end

  ##
  #  TODO: Write tests for this method!
  #
  #  Clones the PipingClassDetail with associated PipingNotes.
  #  Assigns itself to the passed-in PipingClass ID.
  #
  def clone_with_piping_notes(new_piping_class_id)
    new_detail = self.clone
    new_detail.piping_class_id = new_piping_class_id
    new_detail.save!
    self.piping_notes.each do |pn|
      new_detail.piping_notes << pn
    end
  end

  # Calls super to grab a hash of all the users attributes and values
  # Adds another hash for company and role for JSON purposes
  def sext_data(options = {})
    json = super(options)

    if self.piping_notes.size <= 0
      json[:piping_notes] = ''
      json[:piping_note_data] = ''
    else
      these_notes = []
      these_notes_data = []
      self.piping_notes.sort{|a,b| a.note_number <=> b.note_number}.each do |note|
         note_plus_ids = note.sext_data
         note_plus_ids[:piping_class_detail_id] = self.id
         note_plus_ids[:piping_class_id] = self.piping_class_id
        these_notes << note.note_number
        these_notes_data << note_plus_ids
      end
      json[:piping_notes_data] = these_notes_data
      json[:piping_notes] = these_notes
    end



    json[:piping_class] = self.piping_class.class_code

    json[:valve] = self.valve ? self.valve.valve_code : ''
    if self.piping_component
      if self.piping_component.parent_component
        json[:parent_component] = self.piping_component.parent_component.piping_component
        json[:piping_component] = json[:parent_component] + ' : ' + self.piping_component.piping_component
      else
      json[:parent_component] = self.piping_component.piping_component
        json[:piping_component] = json[:parent_component]
    end
    else
      json[:piping_component] = ''
    end

    json[:user_note_data] = get_user_note_data

    # Populates :references_data with an array of PipingReference attributes for
    # listing the references of PipingClassDetails. Defined in PipingReferenceHelper module.
    json[:references_data] = self.get_piping_references

    return json
  end


  # Builds the description string for converting POPV Bill of Material line
  # items to Material Request line items.
  def material_description(sizes = "")
      desc = self.piping_component.piping_component + ", " + self.description
      if sizes.blank?
          return desc
      else
          return sizes + " " + desc
      end
  end

  def size_and_description
    self.size_desc.strip + "  --  " + self.description
  end

  def bc9?
    (description =~ /BC-9/)
  end

  def bc10?
    (description =~ /BC-10/)
  end

  def bc11?
    (description =~ /BC-11/)
  end

  ############################################################################
  # CLASS METHODS
     ############################################################################

    # Finds the associated piping class details for the passed in Valve ID.
    # Returns an array of hashes with four fields in them:
    #   piping_class, component, size, and description.
    # Used for populating the "Associated Piping Classes" table in the WebPOPV
    # Valves resource form.
    def self.find_with_piping_classes_for_valve_id(id)
        records = []
        piping_class_details = self.find(:all,
                                         :conditions => ['valve_id = ?', id],
                                         :include => [:piping_class, :piping_component],
                                         :order => 'piping_classes.class_code ASC')
        piping_class_details.each do |detail|
            records << {
                            :piping_class => detail.piping_class.class_code,
                            :component => detail.piping_component.piping_component,
                            :size => detail.size_desc,
                            :description => detail.description
                       }
        end
        return records
    end

    def self.prepend_text_to_descriptions(ids, text = "")
      ids.each do |id|
        detail = self.find_by_id(id)
        if !detail.blank?
          detail.description = text + " " + detail.description
          detail.description = detail.description.strip
          detail.save
         end
       end
     end

     # Used to find any Details that reference deleted Piping Components.
     # Only finds Details with piping_component_id != NULL.
     def self.find_stragglers
       stragglers = []
       details = PipingClassDetail.find(:all, :include => [:piping_component])
       details.each do |detail|
         if detail.piping_component.nil?
        stragglers << detail
      end
      end
      stragglers
    end


SIZE_HIGHEST = 1000000
  def self.parse_sizes(detail)
    #first, strip out the string

    size = detail.size_desc.upcase.strip
    #unify the wording to be "GREATER rather than LARGER"
    size = size.sub("AND ABOVE","GREATER")
    size = size.sub("LARGER","GREATER")
    size = size.sub("LGR","GREATER")
    size = size.sub(">","GREATER")
    size = size.sub("UP TO","SMALLER")
    size.gsub!("\"\"","\"")
    size.gsub!("'","\"")
    if(size == "1/2\" - 3/4")
      size = "1/2\" - 3/4\""
    end
    if(size == "1/2 - 1-1/2\"")
      size = "1/2\" - 1-1/2\""
    end
    if(size == "1/2\" - 1-1/2")
      size = "1/2\" - 1-1/2\""
    end
    if(size == "1/2\" -1-1/ 2\"")
      size = "1/2\" - 1-1/2\""
    end

    if(size == "2\" - 12")
      size = "2\" - 12\""
    end
    if(size == "6\" - 24")
      size = "6\" - 24\""
    end
    if(size == "10 - 12\"")
      size = "10\" - 12\""
    end
    puts "original size: #{size}"
    if(size == "ALL")
      detail.size_lower = 0
      detail.size_upper = SIZE_HIGHEST
      puts "SIZE:ALL Detail id:#{detail.id}"
    elsif(size == "NONE")
      detail.size_lower = 0
      detail.size_upper = 0
      puts "SIZE:NONE Detail id:#{detail.id}"
    elsif(!size.index("TO BE USED IN INSTRUMENT").blank?)
      detail.size_lower = 0
      detail.size_upper = 0
      puts "SIZE:INSTRUMENT Detail id:#{detail.id}"
    elsif(!size.index("SEE CHART BC").blank?)
      detail.size_lower = 0
      detail.size_upper = 0
      puts "SIZE:INSTRUMENT Detail id:#{detail.id}"
    else
      #count the number of double-quotes
      double_quotes = size.count("\"")
      begin
        #BP CARSON SIZES
        #if([269271,284021,284161,398521,399407,358581,358591,358611,399361

        #BP-CP SIZES
        if([73621,73036,73043,59530,60066,60135,60136

          ].include?(detail.id))
          if(detail.piping_class)
            puts "Piping Class: #{detail.piping_class.class_code}"
          end
          if(detail.piping_component)
            puts "Piping Component: #{detail.piping_component.piping_component}"
          end
          puts "Known error with detail: #{size} id:#{detail.id}"
        elsif(double_quotes == 2)
          #if there are two then we have an upper and lower size
          #everything up to the first double-quote is the lower size
          first_string = size[0,size.index("\"") + 1]
          detail.size_lower = fix_single_size(first_string)

          upper_string = size[first_string.length, size.length]
          puts "lower_size is: #{first_string} | upper_size is: #{upper_string}"
          detail.size_upper = fix_single_size(upper_string)

        elsif((double_quotes == 1) && (!size.index("GREATER").blank?))
          puts "only_size is: GREATER THAN #{size}"
          detail.size_lower = fix_single_size(size)
          detail.size_upper = SIZE_HIGHEST

        elsif((double_quotes == 1) && (!size.index("SMALLER").blank?))
          puts "only_size is: SMALLER THAN #{size}"
          detail.size_lower = 0
          detail.size_upper = fix_single_size(size)

        elsif(double_quotes == 1)
          puts "only_size is JUST SINGLE SIZE #{size}"
          this_size_value = fix_single_size(size)
          detail.size_lower = this_size_value
          detail.size_upper = this_size_value


        else
          if(detail.piping_class)
            puts "Piping Class: #{detail.piping_class.class_code}"
          end
          if(detail.piping_component)
            puts "Piping Component: #{detail.piping_component.piping_component}"
          end
          puts "Wrong number of double quotes: #{double_quotes}"
          puts " SIZE:unknown ::: #{size}:::Detail id:#{detail.id}"
          raise "Unknown Size"
        end
        rescue Exception => e
          puts " SIZE:unknown ::: #{size}:::Detail id:#{detail.id}"
          raise "Unknown Size"
        end

    end
    detail.save!
  end

  def fix_single_size(str)
    str = str.strip

    #fix the 1-1/2 to be 1 - 1/2
    str.gsub!("-"," ")

    #replace mupltiple spaces with single spaces
    str.gsub!(/[ ]{2,}/, " ")


    str.gsub!(".","")
    str.gsub!("&","")
    str.gsub!("(","")
    str.gsub!(")","")

    #remove all spaces from the name
    str = str.strip


    #lots of extra text
    str.gsub!("PIPE/HOSE","")
    str.gsub!("HOSE","")

    str.gsub!("ADAPTERS","")
    str.gsub!("BRANCH SIZES","")
    str.gsub!("HEADER","")
    str.gsub!("PIPE/HOSE","")
    str.gsub!("FITTINGS","")
    str.gsub!("PIPE","")
    str.gsub!("JACKET","")
    str.gsub!("X","")
    str.gsub!("TO","")
    str.gsub!("OD","")

    str.gsub!("ONLY","")

    str.gsub!("AND","")

    str.gsub!("SMALLER","")
    str.gsub!("GREATER","")
    str = str.strip
    #get rid of double quotes
    str.gsub!("\"","")
    str = str.strip

    #get rid of dashes at the front of the string
    if(str[0,1] == "-")
      str = str[1,str.length]
    end
    str = str.strip



    piping_size = PipingSize.find_by_piping_size(str + "\"")
    if(piping_size.blank?)
      puts "unknown individual size:#{str}"
      raise "Unknown Individual Size"
    end
    return piping_size.numerical_size

  end
end

