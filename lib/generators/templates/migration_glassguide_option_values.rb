class CreateGlassguideOptionValues < ActiveRecord::Migration
  def self.up
    create_table :glassguide_option_values,id: false  do |t|
      t.integer :id, null: false
      t.string :make
      t.string :model_family
      t.string :option
      t.integer :years_old
      t.integer :adjust_amount
    end
  end
  
  def self.down
    drop_table :glassguide_option_values
  end
end