module Glassguide
  class Utilities
    def self.import_year_from_nvic(nvic)
      "20" + nvic[3..4]
    end

    def self.import_month_from_nvic(nvic)
      case nvic[-1]
      when "A"
        "Jan"
      when "B"
        "Feb"
      when "C"
        "Mar"
      when "D"
        "Apr"
      when "E"
        "May"
      when "F"
        "Jun"
      when "G"
        "Jul"
      when "H"
        "Aug"
      when "I"
        "Sep"
      when "J"
        "Oct"
      when "K"
        "Nov"
      when "L"
        "Dec"
      end
    end
  end
end