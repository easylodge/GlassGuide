require 'spec_helper'

describe Glassguide::Utilities do
  describe ".import_year_from_nvic" do
    it "returns year based on nvic" do
      expect(Glassguide::Utilities.import_year_from_nvic('S4T13F')).to eq("2013")
    end
  end

  describe ".import_month_from_nvic" do
    it "returns year based on nvic" do
      expect(Glassguide::Utilities.import_month_from_nvic('S4T13F')).to eq("Jun")
    end
  end

end