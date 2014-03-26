module Glassguide
  class SelectedVehicle < ActiveRecord::Base
    belongs_to :motor_vehicle_application, :class_name => "ApplicationMotorVehicle", :foreign_key => "application_motor_vehicle_id"
    self.table_name "glasses_selected_vehicles"
  
    validates_presence_of :year, :make, :family, :variant, :style, :transmission, :series, :engine, :unless => :fields_optional?
  
    delegate :config, :to => :motor_vehicle_application, :allow_nil => true
  
    serialize :selected_factory_options
  
    # Checks the application and config to see if vehicle selection is optional.
    #
    # Returns Boolean - true if vehicle selection is optional, false if not.
    def fields_optional?
      motor_vehicle_application.try(:vehicle_details_unknown) &&
        config.try(:[], :allow_empty_selection) == true
    end
  end     
end