module Glassguide
  class KilometerVehicle < ActiveRecord::Base
    self.table_name = "glassguide_kilometer_vehicles"
    self.primary_key = :code
    
    # def custom_primary_key=(val)
    #   self[:code] = val
    # end
  end   
end
