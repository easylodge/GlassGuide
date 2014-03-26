module Glassguide
  class Option < ActiveRecord::Base
    self.table_name = "glassguide_options"
    
    # scope :standard, :conditions => {:rec_type => 'Standard:'}
    # scope :optional, :conditions => {:rec_type => 'Optional:'}
    
    # def option_details
    #   option_codes.split(',').map(&:strip).inject([]) do |store, option|
    #     option = option.split(':', 2).map(&:strip)
        
    #     details = Glasses::OptionDetail.find_by_code(option[0])
    #     details.cost_price = option[1].to_i if option.size == 2
    #     store << details
    #   end
    # end
    
    # alias :details :option_details
    
    # def value_of_options(option_codes)
    #   option_details.select { |option| option_codes.include?(option.code) }    
    # end
    
  end   
end
