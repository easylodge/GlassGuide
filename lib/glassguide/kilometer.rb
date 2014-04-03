module Glassguide
  class Kilometer < ActiveRecord::Base
    self.table_name = "glassguide_kilometers"
    self.primary_key = :id


    scope :over,-> (km_diff, km_category) {where(:up_to_kms >= km_diff && :over_under == "O" && :km_category == km_category).sort(:up_to_kms).first.adjust_amount }
    scope :under,-> (km_diff, km_category) {where(:up_to_kms >= km_diff && :over_under == "U" && :km_category == km_category).sort(:up_to_kms).first.adjust_amount }
  end  
end
