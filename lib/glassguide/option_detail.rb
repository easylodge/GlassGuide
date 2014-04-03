module Glassguide
  class OptionDetail < ActiveRecord::Base
    self.table_name = "glassguide_option_details"
    self.primary_key = :code

    attr_accessor :cost_price

    # def initialize(*args)
    #   super(args)
    #   self.cost_price = 0
    # end


    # attr_accessor :value, 0
    # attr_accessor :selected, 0

  end   
end
