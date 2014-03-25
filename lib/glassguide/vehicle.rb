module Glassguide
  class Vehicle < ActiveRecord::Base
    self.table_name = "glasses_vehicles"
    self.primary_key = :code

    def custom_primary_key=(val)
      self[:code] = val
    end

    # named_scope :years, :select => 'DISTINCT(`glasses_vehicles`.`year`)', :order => 'year DESC'

    def self.years
      find(:all, :group => 'year', :select => 'year')
    end

    named_scope :makes, :select => 'DISTINCT(`glasses_vehicles`.`make`)', :order => 'make ASC'
    named_scope :families, :select => 'DISTINCT(`glasses_vehicles`.`family`)', :order => 'family ASC'
    named_scope :variants, :select => 'DISTINCT(`glasses_vehicles`.`variant`)', :order => 'variant ASC'
    named_scope :styles, :select => 'DISTINCT(`glasses_vehicles`.`style`)', :order => 'style ASC'
    named_scope :transmissions, :select => 'DISTINCT(`glasses_vehicles`.`transmission`)', :order => 'transmission ASC'
    named_scope :series, :select => 'DISTINCT(`glasses_vehicles`.`series`)', :order => 'series ASC'
    named_scope :engines, :select => 'DISTINCT(`glasses_vehicles`.`engine`), `glasses_vehicles`.`size`, `glasses_vehicles`.`cyl`', :order => 'engine ASC'

    # By scopes
    named_scope :by_year, lambda { |year| { :conditions => (year == 'New') ? ['price_new IS NOT NULL'] : ['year = ? ', year] } }
    named_scope :by_make, lambda { |make| { :conditions => {:make => make} } }
    named_scope :by_family, lambda { |family| { :conditions => {:family => family} } }
    named_scope :by_variant, lambda { |variant| { :conditions => {:variant => variant} } }
    named_scope :by_style, lambda { |style| { :conditions => {:style => style} } }
    named_scope :by_transmission, lambda { |transmission| { :conditions => {:transmission => transmission} } }
    named_scope :by_series, lambda { |series| { :conditions => {:series => series} } }
    named_scope :by_engine, lambda { |engine| { :conditions => {:engine => engine} } }
    named_scope :by_vehicle_type, lambda { |vehicle_type| { :conditions => {:motorcycle => (vehicle_type.downcase == 'motorcycle')} } }

    has_one :standard_options, :class_name => "Glasses::Option", :foreign_key => "vehicle_code", :conditions => {:rec_type => 'Standard:'}
    has_one :optional_options, :class_name => "Glasses::Option", :foreign_key => "vehicle_code", :conditions => {:rec_type => 'Optional:'}
    has_many :options, :class_name => "Glasses::Option", :foreign_key => "vehicle_code"

    def photo
      # path = "https://s3.amazonaws.com/storage.easylodge.com.au/easylodge/public/glasses/#{nvic}.jpg"
    end

  end
end


