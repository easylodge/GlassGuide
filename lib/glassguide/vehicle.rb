module Glassguide
  class Vehicle < ActiveRecord::Base
    self.table_name = "glassguide_vehicles"
    self.primary_key = :code

    def custom_primary_key=(val)
      self[:code] = val
    end

    #scope :motorcycle, -> { where(motorcycle: true) }
    # named_scope :years, :select => 'DISTINCT(`glassguide_vehicles`.`year`)', :order => 'year DESC'

    def self.years
      find(:all, :group => 'year', :select => 'year')
    end

    #scope :makes, :select => 'DISTINCT(`glassguide_vehicles`.`make`)', :order => 'make ASC'
    #scope :families, :select => 'DISTINCT(`glassguide_vehicles`.`family`)', :order => 'family ASC'
    #scope :variants, :select => 'DISTINCT(`glassguide_vehicles`.`variant`)', :order => 'variant ASC'
    #scope :styles, :select => 'DISTINCT(`glassguide_vehicles`.`style`)', :order => 'style ASC'
    #scope :transmissions, :select => 'DISTINCT(`glassguide_vehicles`.`transmission`)', :order => 'transmission ASC'
    #scope :series, :select => 'DISTINCT(`glassguide_vehicles`.`series`)', :order => 'series ASC'
    #scope :engines, :select => 'DISTINCT(`glassguide_vehicles`.`engine`), `glassguide_vehicles`.`size`, `glassguide_vehicles`.`cyl`', :order => 'engine ASC'
    # # By scopes

    
    scope :select_year ,->(year) {where((year.to_s == 'New') ? ['price_new IS NOT NULL'] : ['year = ? ', year.to_s])}
    scope :select_make ,->(make) {where(:make => make)}    
    scope :select_families ,->(family) {where("family=?", family)}    
    scope :select_variants ,->(variant) {where(:variant => variant)}    
    scope :select_styles ,->(style) {where(:style => style)}    
    scope :select_transmission ,->(transmission) {where(:transmission => transmission)}    
    scope :select_series ,->(series) {where(:series => series)}    
    scope :select_engines ,->(engine) {where(:engine => engine)}  

    def self.makes(make)
      return self.select_make(make).uniq
    end  
    
    
    # scope :by_vehicle_type, lambda { |vehicle_type| { :conditions => {:motorcycle => (vehicle_type.downcase == 'motorcycle')} } }

    # has_one :standard_options, :class_name => "Glasses::Option", :foreign_key => "vehicle_code", :conditions => {:rec_type => 'Standard:'}
    # has_one :optional_options, :class_name => "Glasses::Option", :foreign_key => "vehicle_code", :conditions => {:rec_type => 'Optional:'}
    # has_many :options, :class_name => "Glasses::Option", :foreign_key => "vehicle_code"

    def photo
      # path = "https://s3.amazonaws.com/storage.easylodge.com.au/easylodge/public/glasses/#{nvic}.jpg"
    end

  end
end


