class CreateGlassguideOptionDetails < ActiveRecord::Migration
  def self.up
    create_table :glassguide_option_details,id: false do |t|
      t.integer :id ,null: false
      t.string :code
      t.string :name
      t.timestamps
    end  
  end

  def self.down
    drop_table :glassguide_option_details    
  end
end