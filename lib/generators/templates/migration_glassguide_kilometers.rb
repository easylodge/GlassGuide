class CreateGlassguideKilometers < ActiveRecord::Migration
  def self.up
    create_table :glassguide_kilometers,id: false  do |t|
      t.integer :id, null: false
      t.string  :km_category
      t.string  :over_under
      t.string  :up_to_kms
      t.decimal :adjust_amount
    end
  end
  
  def self.down
     drop_table :glassguide_kilometers
  end
end