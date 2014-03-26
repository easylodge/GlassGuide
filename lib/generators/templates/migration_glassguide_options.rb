class CreateGlassguideOptions < ActiveRecord::Migration
  def self.up
    create_table :glassguide_options ,id: false do |t|
      t.integer :id
      t.string :vehicle_code
      t.string :option_code
      t.string :nvic
      t.string :rec_type
      t.timestamps
    end  
  end
  
  def self.down
    drop_table :glassguide_options
  end
  
end