class CreateGlassguideVehicles < ActiveRecord::Migration
  def self.up
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
      t.string  :model
      t.string  :engine_type
      t.timestamps
    end    
  end
  
  def self.down
    drop_table :glassguide_vehicles
  end
end