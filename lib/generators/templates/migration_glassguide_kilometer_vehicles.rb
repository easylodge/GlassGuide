class CreateGlassguideKilometerVehicles < ActiveRecord::Migration
  def self.up
    create_table :glassguide_kilometer_vehicles,id: false   do |t|
      t.integer :id
      t.string :code, null: true
      t.string :nvic
      t.string :km_category
      t.integer :average_kilometres_in_thousands
    end
  end
  
  def self.down
    drop_table :glassguide_kilometer_vehicles
  end
end