ActiveRecord::Schema.define do
  self.verbose = false

    create_table :glassguide_kilometer_vehicles,id: false   do |t|
      t.integer :id
      t.string :code, null: true
      t.string :nvic
      t.string :km_category
      t.integer :average_kilometers_in_thousands
    end

    create_table :glassguide_kilometers,id: false  do |t|
      t.integer :id, null: true
      t.string  :km_category
      t.string  :over_under
      t.integer :up_to_kms
      t.decimal :adjust_amount
    end

    create_table :glassguide_option_details,id: false do |t|
      t.integer :id 
      t.string :code
      t.string :name
      t.timestamps
    end  
    
    create_table :glassguide_option_values,id: false  do |t|
      t.integer :id
      t.string :make
      t.string :model_family
      t.string :option
      t.integer :years_old
      t.integer :adjust_amount
    end   

    create_table :glassguide_options ,id: false do |t|
      t.integer :id
      t.string :vehicle_code
      t.string :option_codes
      t.string :nvic
      t.string :rec_type
      t.timestamps
    end 

    create_table :glassguide_vehicles,id: false do |t|
      t.integer :id 
      t.string  :code, null: true
      t.string  :nvic
      t.string  :mth
      t.string  :year
      t.string  :make
      t.string  :family
      t.string  :variant
      t.string  :series
      t.string  :style
      t.string  :engine
      t.string  :cc
      t.string  :size
      t.string  :transmission
      t.string  :cyl
      t.integer :price_private_sale
      t.integer :price_trade_in
      t.integer :price_trade_low
      t.integer :price_dealer_retail
      t.integer :price_new
      t.string  :width
      t.string  :bt
      t.string  :et
      t.string  :tt
      t.boolean :motorcycle
      t.string  :valve_gear
      t.string  :borexstroke
      t.string  :kw
      t.string  :comp_ratio
      t.string  :engine_cooling
      t.string  :kerb_weight
      t.string  :wheelbase
      t.string  :seat_height
      t.string  :drive
      t.string  :front_tyres
      t.string  :rear_tyres
      t.string  :front_rims
      t.string  :rear_rims
      t.string  :ftank
      t.string  :warranty_mths
      t.string  :warranty_kms
      t.string  :country
      t.string  :released_date
      t.string  :discont_date
      t.timestamps
    end
end