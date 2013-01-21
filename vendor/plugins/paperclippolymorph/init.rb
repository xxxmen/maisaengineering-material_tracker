require 'acts_as_polymorphic_paperclip'
ActiveRecord::Base.send(:include, LocusFocus::Acts::PolymorphicPaperclip)

# Commented out by Adam Grant so that it doesn't load these files. Instead, 
# I have abstracted out these models into app/models and copied their core 
# functionality there, so the model definitions aren't spread out. It was 
# causing me some problems, to say the least:

#require File.dirname(__FILE__) + '/lib/asset'
#require File.dirname(__FILE__) + '/lib/attaching'
