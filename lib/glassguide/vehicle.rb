module Glassguide
  class Vehicle < ::ActiveRecord::Base
    self.table_name = "glassguide_vehicles"
    self.primary_key = :code

    has_many :options, :class_name => "Glassguide::Option", :foreign_key => "vehicle_code"
    has_one :standard_options, -> {where(rec_type: 'Standard:')},class_name: "Glassguide::Option", foreign_key: "vehicle_code"
    has_one :optional_options, -> {where(rec_type: 'Optional:')},class_name: "Glassguide::Option", foreign_key: "vehicle_code"

    scope :motorcycles_only,-> {where(:motorcycle => true)}
    scope :vehicles_only,-> {where(:motorcycle => false)} 
    
    scope :select_year ,->(year) {where((year.to_s == 'New') ? ['price_new IS NOT NULL'] : ['year = ? ', year.to_s])}
    scope :select_make ,->(make) {where(:make => make)}    
    scope :select_families ,->(family) {where("family=?", family)}    
    scope :select_variants ,->(variant) {where(:variant => variant)}    
    scope :select_styles ,->(style) {where(:style => style)}    
    scope :select_transmission ,->(transmission) {where(:transmission => transmission)}    
    scope :select_series ,->(series) {where(:series => series)}    
    scope :select_engines ,->(engine) {where(:engine => engine)}
    scope :select_vehicle_type ,->(choice) {where(:motorcycle => choice)}   



    scope :list_year, -> {pluck(:year).uniq.sort}
    scope :list_make, -> {pluck(:make).uniq.sort}
    scope :list_families, -> {pluck(:family).uniq.sort}
    scope :list_variants, -> {pluck(:variant).uniq.sort}
    scope :list_styles, -> {pluck(:style).uniq.sort}
    scope :list_transmission, -> {pluck(:transmission).uniq.sort}
    scope :list_series, -> {pluck(:series).uniq.sort}
    scope :list_engines, -> {pluck(:engine).uniq.sort}

    def custom_primary_key=(val)
      self[:code] = val
    end
      
       
    ##Not Testing due to time moving forward  
    def years_old
      ((Time.now - Date.parse("#{mth} #{year}").to_time).to_f / 1.year).round
    end

    ##Not Testing due to directory not defined in  moving forward 
    def photo
      glassguide_details = YAML.load_file("#{Rails.root}/config/glassguide_config.yml")
      return "/#{glassguide_details['image_directory']}/#{self.nvic}.jpg"    
    end

    def average_kilometers()
      kms = Glassguide::KilometerVehicle.find(code).average_kilometers_in_thousands.to_i
      kms = kms * 1000
      return kms
    rescue
      return 0
    end

    # Not Ready
    def kilometer_adjustment(actual = average_kilometers)
      direction = average_kilometers < actual ? 'O' : 'U'
      km_category = Glassguide::KilometerVehicle.find(code).km_category
      km_diff = actual - average_kilometers

      max = Glassguide::Kilometer.where(:over_under == direction && :km_category == km_category).sort.last.up_to_kms   
      km_diff = (km_diff.abs > max) ? max : km_diff.abs


      if average_kilometers < actual
        #we are looking for price adjustments where we have driven MORE than the indicated above average distance up to the next bracket
        Glassguide::Kilometer.where("up_to_kms>=?", km_diff).where(:over_under => "O", :km_category => km_category).order("up_to_kms ASC").first.adjust_amount.to_i * -1
      elsif average_kilometers > actual
        #we are looking for price adjustments where we have driven LESS than the indicated above average distance up to the next bracket
        Glassguide::Kilometer.where("up_to_kms>=?", km_diff).where(:over_under => "U", :km_category => km_category).order("up_to_kms ASC").first.adjust_amount.to_i
      elsif average_kilometers == actual
        # no difference equals no adjustment
        0
      end
    rescue
        return 0
    end

    def kilometer_adjustment_dealer_retail(actual = average_kilometers, do_km_adjustment=true)
      do_km_adjustment ? kilometer_adjustment(actual) : 0
      kilometer_adjustment(actual)
    end

    def kilometer_adjustment_private_sale(actual = average_kilometers, do_km_adjustment=true)
      kilometer_adjustment_dealer_retail(actual, do_km_adjustment)
    end

    def kilometer_adjustment_trade_in(actual = average_kilometers, do_km_adjustment=true)
      do_km_adjustment ? (kilometer_adjustment(actual) * 0.5) : 0
    end

    def kilometer_adjustment_trade_low(actual = average_kilometers, do_km_adjustment=true)
      do_km_adjustment ? (kilometer_adjustment(actual) * 0.3) : 0
    end

    def price_adjusted_dealer_retail(actual = average_kilometers, options = [], do_km_adjustment=true)
      price_dealer_retail.to_i + kilometer_adjustment_dealer_retail(actual, do_km_adjustment) + value_of_options(options)

    end

    def price_adjusted_private_sale(actual = average_kilometers, options = [], do_km_adjustment=true)
      price_private_sale.to_i + kilometer_adjustment_private_sale(actual, do_km_adjustment) + value_of_options(options)
    end

    def price_adjusted_trade_in(actual = average_kilometers, options = [], do_km_adjustment=true)
      price_trade_in.to_i + kilometer_adjustment_trade_in(actual, do_km_adjustment) + (value_of_options(options) * 0.5)
    rescue
      0
    end

    def price_adjusted_trade_low(actual = average_kilometers, options = [], do_km_adjustment=true)
      price_trade_low.to_i + kilometer_adjustment_trade_low(actual, do_km_adjustment) + (value_of_options(options) * 0.3)
    rescue
      0
    end

    def retail_price
      return price_dealer_retail.to_i if price_new.to_i.zero?
      price_new.to_i
    end

    # attr_accessor_with_default :selected_factory_options, []

    def options_factory
      optional_options.details.inject([]) do |store, option|
        option.value = (Glassguide::OptionValue.find_by_option_and_years_old(option.code, self.years_old).adjust_amount rescue 0)
        store << option
      end
    # rescue
      # []
    end

    def options_standard
      standard_options ? standard_options.details : nil
    end

    def options_optional
      optional_options ? optional_options.details : nil
    end

    def value_of_options(option_codes)
      Glassguide::OptionValue.for_codes(option_codes, self.years_old).sum(:adjust_amount)
    end

    def deprication_table(kilometers = average_kilometers, do_km_adjustment = true, option_codes = {}, year_new = false)
    option_codes # needs to be send through as ["NVIC", "TR5", "GARBLE"]

      if (!self.price_new.nil? || self.price_new.to_i > 0) && year_new == true
        depreciation_table = {:new_vehicle    => true,
                              :price_new      => self.price_new,
                              :options_amount => (self.value_of_options(option_codes) rescue 0),
                              :adjusted_value => (self.price_new + self.value_of_options(option_codes))
                            }
      else
        depreciation_table = {
          :price_dealer_retail => self.price_dealer_retail.to_f,
          :price_private_sale => self.price_private_sale.to_f,
          :price_trade_in => self.price_trade_in.to_f,
          :price_trade_low => self.price_trade_low.to_f,

          :adjust_dealer_retail_amount => self.kilometer_adjustment_dealer_retail(kilometers.to_f, do_km_adjustment).to_f,
          :adjust_private_sale_amount => self.kilometer_adjustment_private_sale(kilometers.to_f, do_km_adjustment).to_f,
          :adjust_trade_in_amount => self.kilometer_adjustment_trade_in(kilometers.to_f, do_km_adjustment).to_f,
          :adjust_trade_low_amount => self.kilometer_adjustment_trade_low(kilometers.to_f, do_km_adjustment).to_f,

          :options_dealer_retail_amount => (self.value_of_options(option_codes) rescue 0).to_f,
          :options_private_sale_amount => (self.value_of_options(option_codes) rescue 0).to_f,
          :options_trade_in_amount => (self.value_of_options(option_codes) * 0.5 rescue 0).to_f,
          :options_trade_low_amount => (self.value_of_options(option_codes) * 0.3 rescue 0).to_f,

          :adjusted_dealer_retail => self.price_adjusted_dealer_retail(kilometers.to_f, option_codes, do_km_adjustment).to_f,
          :adjusted_private_sale => self.price_adjusted_private_sale(kilometers.to_f, option_codes, do_km_adjustment).to_f,
          :adjusted_trade_in => self.price_adjusted_trade_in(kilometers.to_f, option_codes, do_km_adjustment).to_f,
          :adjusted_trade_low => self.price_adjusted_trade_low(kilometers.to_f, option_codes, do_km_adjustment).to_f
        }
      end

      return depreciation_table
    end

    def as_json(options = {})
      {
        :code => code,
        :nvic => nvic,
        :photo => photo,
        :year => year,
        :make => make,
        :family => family,
        :variant => variant,
        :series => series,
        :style => style,
        :engine => engine,
        :transmission => transmission
      }
    end

  end
end


