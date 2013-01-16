module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module LogEdits
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_log_edits(options = {})
          has_many :log_edits, :as => :loggable
          after_save :log_edit
          
          include ActiveRecord::Acts::LogEdits::InstanceMethods
          extend ActiveRecord::Acts::LogEdits::SingletonMethods          
        end
      end
      
      module InstanceMethods
        private
        def log_edit
          LogEdit.create(:loggable => self)
        end
      end

      module SingletonMethods
        # this is a basic merge method.  Override this for more complex merge operations
        def merge old_attributes, new_attributes
          # get id from old_attributes, if it's 0, then this is a new object
          if (old_attributes[self.primary_key]==0)
            obj = self.new(new_attributes)
            obj.save!
          else # obj already exists, find it
            obj = obj = self.find(old_attributes[self.primary_key])
            obj.update_attributes! new_attributes
          end
          obj
        rescue ActiveRecord::StaleObjectError => e
          # couldn't update because of version number mismatch
          return advanced_merge(old_attributes, new_attributes, obj.reload)
        rescue ActiveRecord::RecordInvalid => e
          # couldn't save the object
          return validation_failed(obj)
        rescue ActiveRecord::RecordNotFound => e
          # couldn't find the object
          return invalid_id(old_attributes)
        end
        
        def merge_create new_attributes
          obj = self.new(new_attributes)
          obj.save!
          obj
        rescue ActiveRecord::StaleObjectError => e
          # couldn't update because of version number mismatch
          return lock_version_failed(obj.reload)
        rescue ActiveRecord::RecordInvalid => e
          # couldn't save the object
          return validation_failed(obj)
        rescue ActiveRecord::RecordNotFound => e
          # couldn't find the object
          return invalid_id(new_attributes)
        end
        
        def merge_update new_attributes
          obj = self.find(new_attributes[self.primary_key])
          obj.update_attributes! new_attributes
          obj
        rescue ActiveRecord::StaleObjectError => e
          # couldn't update because of version number mismatch
          return lock_version_failed(obj.reload)
        rescue ActiveRecord::RecordInvalid => e
          # couldn't save the object
          return validation_failed(obj)
        rescue ActiveRecord::RecordNotFound => e
          # couldn't find the object
          return invalid_id(new_attributes)
        rescue NoMethodError
          return validation_failed(obj)
        end
        
        protected
        # override this function def MyTable.advancded_merge to give your model
        # smarter merging abilities
        def advanced_merge o, n, c
          return version_mismatch(o, n, c)
        end

        def version_mismatch o, n, c
          {'old_data' => o, 'new_data' => n, 'current_data' => c.attributes, 'error' => 'Version Mismatch'}
        end
        
        def validation_failed c
          {'current_data' => c.attributes, 'error' => 'Validation Failed', 'errors' => c.errors}
        end
        
        def lock_version_failed c
          {'current_data' => c.attributes, 'error' => 'Lock Version Mismatch', 'errors' => c.errors}
        end
                
        def invalid_id o
          {'old_data' => o, 'error' => 'Invalid ID'}
        end
      end      
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::LogEdits