class AddGlassguideTables < ActiveRecord::Migration
  def self.up
    create_table :glassguide_kilometers do |t|
      t.string :km_category
      t.string :over_under
      t.string :up_to_kms
      t.decimal :adjust_amount
    end
    
    create_table :glassguide_kilometer_vehicles do |t|
      t.string :code
      t.string :nvic
      t.string :km_category
      t.integer :average_kilometres_in_thousands
    end
    
    create_table :glassguide_option_values do |t|
      t.string :make
      t.string :model_family
      t.string :option
      t.integer :years_old
      t.integer :adjust_amount
    end
    
    create_table :glassguide_options do |t|
      t.string :vehicle_code
      t.string :option_code
      t.string :nvic
      t.string :rec_type
      t.timestamps
    end
    
    create_table :glassguide_option_details do |t|
      t.string :code
      t.string :name
      t.timestamps
    end
    
    create_table :glassguide_vehicles do |t|
      t.string :code
      t.string :nvic
      t.string :mth
      t.string :year
      t.string :make
      t.string :family
      t.string :variant
      t.string :series
      t.string :style
      t.string :engine
      t.string :cc
      t.string :size
      t.string :transmission
      t.string :cyl
      t.integer :price_private_sale
      t.integer :price_trade_in
      t.integer :price_trade_low
      t.integer :price_dealer_retail
      t.integer :price_new
      t.string :width
      t.string :bt
      t.string :et
      t.string :tt
      t.boolean :motorcycle
      t.string :valve_gear
      t.string :bore_stroke
      t.string :kw
      t.string :comp_ratio
      t.string :engine_cooling
      t.string :kerb_weight
      t.string :wheelbase
      t.string :seat_height
      t.string :drive
      t.string :front_tyres
      t.string :rear_tyres
      t.string :front_rims
      t.string :rear_rims
      t.string :ftank
      t.string :warranty_mths
      t.string :warranty_kms
      t.string :country
      t.string :released_date
      t.string :discont_date
      t.timestamps
    end

    
  end

end