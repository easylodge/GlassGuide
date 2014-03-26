module Glassguide
  class OptionValue < ActiveRecord::Base
    self.table_name = "glassguide_option_values"
    # named_scope :for_codes, lambda { |codes, years_old| { :conditions => {:glasses_option_values => {:option => codes, :years_old => years_old}} } }
  end   
end
