module Glassguide
  class OptionValue < ActiveRecord::Base
    self.table_name = "glassguide_option_values"
    self.primary_key = "id"

    scope :for_codes, -> (codes,years_old) {where(:option => codes, :years_old => years_old)}
  end   
end
