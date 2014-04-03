require 'spec_helper'

describe Glassguide::Vehicle do
  # it{expect(subject).to respond_to(:id)}

  context "attrs" do
    it { expect(subject).to respond_to :id } 
    it { expect(subject).to respond_to :code }
    it { expect(subject).to respond_to :nvic }
    it { expect(subject).to respond_to :mth }
    it { expect(subject).to respond_to :year }
    it { expect(subject).to respond_to :make }
    it { expect(subject).to respond_to :family }
    it { expect(subject).to respond_to :variant }
    it { expect(subject).to respond_to :series }
    it { expect(subject).to respond_to :style }
    it { expect(subject).to respond_to :engine }
    it { expect(subject).to respond_to :cc }
    it { expect(subject).to respond_to :size }
    it { expect(subject).to respond_to :transmission }
    it { expect(subject).to respond_to :cyl }
    it { expect(subject).to respond_to :price_private_sale }
    it { expect(subject).to respond_to :price_trade_in }
    it { expect(subject).to respond_to :price_trade_low }
    it { expect(subject).to respond_to :price_dealer_retail }
    it { expect(subject).to respond_to :price_new }
    it { expect(subject).to respond_to :width }
    it { expect(subject).to respond_to :bt }
    it { expect(subject).to respond_to :et }
    it { expect(subject).to respond_to :tt }
    it { expect(subject).to respond_to :motorcycle }
    it { expect(subject).to respond_to :valve_gear }
    it { expect(subject).to respond_to :borexstroke }
    it { expect(subject).to respond_to :kw }
    it { expect(subject).to respond_to :comp_ratio }
    it { expect(subject).to respond_to :engine_cooling }
    it { expect(subject).to respond_to :kerb_weight }
    it { expect(subject).to respond_to :wheelbase }
    it { expect(subject).to respond_to :seat_height }
    it { expect(subject).to respond_to :drive }
    it { expect(subject).to respond_to :front_tyres }
    it { expect(subject).to respond_to :rear_tyres }
    it { expect(subject).to respond_to :front_rims }
    it { expect(subject).to respond_to :rear_rims }
    it { expect(subject).to respond_to :ftank }
    it { expect(subject).to respond_to :warranty_mths }
    it { expect(subject).to respond_to :warranty_kms }
    it { expect(subject).to respond_to :country }
    it { expect(subject).to respond_to :released_date }
    it { expect(subject).to respond_to :discont_date }
  end



  context "scopes" do
    10.times do
      Glassguide::Vehicle.create(:motorcycle => false)
      Glassguide::Vehicle.create(:motorcycle => true)
    end

    it "for narrowing down to vehicles only" do
      expect(Glassguide::Vehicle.vehicles_only.count).to eq(10)
    end

    it "for narrowing down to motorcycles only" do
      expect(Glassguide::Vehicle.motorcycles_only.count).to eq(10)
    end

    ## motorcycle and vehicles use checks the same field

    it "for narrowing down by year" do
      10.times do
        Glassguide::Vehicle.create(:year => "1990")
        Glassguide::Vehicle.create(:year => "1992")
      end
      expect(Glassguide::Vehicle.select_year("1990").count).to eq(10)
    end

    it "for narrowing down by make" do
      10.times do
        Glassguide::Vehicle.create(:make => "XXY")
        Glassguide::Vehicle.create(:make => "YXX")
      end
      expect(Glassguide::Vehicle.select_make("XXY").count).to eq(10)
    end

    it "for narrowing down by family" do
      10.times do
        Glassguide::Vehicle.create(:family => "QAZ")
        Glassguide::Vehicle.create(:family => "ZAQ")
      end
      expect(Glassguide::Vehicle.select_families("ZAQ").count).to eq(10)
    end

    it "for narrowing down by variants" do
      10.times do
        Glassguide::Vehicle.create(:variant => "WSX")
        Glassguide::Vehicle.create(:variant => "XSW")
      end
      expect(Glassguide::Vehicle.select_variants("WSX").count).to eq(10)
    end

    it "for narrowing down by styles" do
      10.times do
        Glassguide::Vehicle.create(:style => "EDC")
        Glassguide::Vehicle.create(:style => "CDE")
      end
      expect(Glassguide::Vehicle.select_styles("EDC").count).to eq(10)
    end

    it "for narrowing down by transmissions" do
      10.times do
        Glassguide::Vehicle.create(:transmission => "RFV")
        Glassguide::Vehicle.create(:transmission => "VFR")
      end
      expect(Glassguide::Vehicle.select_transmission("RFV").count).to eq(10)
    end

    it "for narrowing down by series" do
      10.times do
        Glassguide::Vehicle.create(:series => "TGB")
        Glassguide::Vehicle.create(:series => "BGT")
      end
      expect(Glassguide::Vehicle.select_series("TGB").count).to eq(10)
    end

    it "for narrowing down by engines" do
      10.times do
        Glassguide::Vehicle.create(:engine => "YHN")
        Glassguide::Vehicle.create(:engine => "NHY")
      end
      expect(Glassguide::Vehicle.select_engines("YHN").count).to eq(10)
    end

    it "for building a list of years" do
      # there was 10 1990, but it only retrieved the one value
      expect(Glassguide::Vehicle.where("year!=?", "").list_year).to eq(["1990", "1992"])
    end

    it "for building a list of years" do
      # there was 10 1990, but it only retrieved the one value
      expect(Glassguide::Vehicle.where("make!=?", "").list_make).to eq(["XXY", "YXX"])
    end

    it "for building a list of families" do
      # there was 10 1990, but it only retrieved the one value
      expect(Glassguide::Vehicle.where("family!=?", "").list_families).to eq(["QAZ", "ZAQ"])
    end

    it "for building a list of variants" do
      # there was 10 1990, but it only retrieved the one value
      expect(Glassguide::Vehicle.where("variant!=?", "").list_variants).to eq(["WSX", "XSW"])
    end

    it "for building a list of styles" do
      # there was 10 1990, but it only retrieved the one value
      expect(Glassguide::Vehicle.where("style!=?", "").list_styles).to eq(["CDE", "EDC"])
    end

    it "for building a list of transmissions" do
      # there was 10 1990, but it only retrieved the one value
      expect(Glassguide::Vehicle.where("transmission!=?", "").list_transmission).to eq(["RFV", "VFR"])
    end

    it "for building a list of series" do
      # there was 10 1990, but it only retrieved the one value
      expect(Glassguide::Vehicle.where("series!=?", "").list_series).to eq(["BGT", "TGB"])
    end

    it "for building a list of engines" do
      # there was 10 1990, but it only retrieved the one value
      expect(Glassguide::Vehicle.where("engine!=?", "").list_engines).to eq(["NHY", "YHN"])
    end
  end

  context "Functions" do
    it "set custom primary key" do
      #this function is only used for uploading
      x = Glassguide::Vehicle.create()
      x.custom_primary_key=("leCode")
      expect(x.code).to eq("leCode")
    end

    it "Test Retrieval Average Kilometers" do
      #this function is only used for uploading
      x = Glassguide::Vehicle.create(:code => "ABCDF")
      y = Glassguide::KilometerVehicle.create(:code => "ABCDF",:average_kilometers_in_thousands => 10)
      #This should return the value * 1000 because the column is /1000 of the actual value
      expect(x.average_kilometers).to eq(10000)
    end


      Glassguide::Kilometer.create(:up_to_kms => 10000, :over_under => "O", :km_category => "A", :adjust_amount => 700 )
      Glassguide::Kilometer.create(:up_to_kms => 15000, :over_under => "O", :km_category => "A", :adjust_amount => 900 )

      Glassguide::Kilometer.create(:up_to_kms => 10000, :over_under => "U", :km_category => "A", :adjust_amount => 500 )
      Glassguide::Kilometer.create(:up_to_kms => 15000, :over_under => "U", :km_category => "A", :adjust_amount => 400 )


    it "Test Kilometer adjustment -- with no paramters" do
      x = Glassguide::Vehicle.create(:code => "QWERT")
      Glassguide::KilometerVehicle.create(:code => "QWERT", :km_category => "A", :average_kilometers_in_thousands => 10)
      expect(x.kilometer_adjustment).to eq(0)
    end

    it "Test Kilometer adjustment -- with km above the average paramters" do
      x = Glassguide::Vehicle.create(:code => "ASDFG")
      Glassguide::KilometerVehicle.create(:code => "ASDFG", :km_category => "A", :average_kilometers_in_thousands => 10)
      expect(x.kilometer_adjustment(60000)).to eq(-900)
    end

    it "Test Kilometer adjustment -- with km below the average paramters" do
      x = Glassguide::Vehicle.create(:code => "ZXCV")
      Glassguide::KilometerVehicle.create(:code => "ZXCV", :km_category => "A", :average_kilometers_in_thousands => 10)
      expect(x.kilometer_adjustment(5000)).to eq(500)
    end

    it "Test deprication table -- With Option Codes and with Kilometer Adjustment" do
      y = Date.today - 9.years
      x = Glassguide::Vehicle.create(:code => "PLM12", :year => y.year, :mth => y.strftime("%b"), :price_dealer_retail => 15000, :price_private_sale => 13000, :price_trade_in => 11000, :price_trade_low => 10000 )
      Glassguide::KilometerVehicle.create(:code => "PLM12", :km_category => "A", :average_kilometers_in_thousands => 10)
      Glassguide::KilometerVehicle.create(:code => "PLM13", :km_category => "B", :average_kilometers_in_thousands => 10)
      Glassguide::OptionValue.create(:option => "AP", :years_old => 9, :adjust_amount => 200)
      Glassguide::OptionValue.create(:option => "AW18", :years_old => 9, :adjust_amount => 700)
      Glassguide::OptionValue.create(:option => "LP", :years_old => 9, :adjust_amount => 300)
      Glassguide::OptionValue.create(:option => "AP7", :years_old => 9, :adjust_amount => 900)


      expect(x.deprication_table(17000, true, ["AP", "AW18", "LP"])).to eq({:price_dealer_retail=>15000, :price_private_sale=>13000, :price_trade_in=>11000, :price_trade_low=>10000, :adjust_dealer_retail_amount=>-700, :adjust_private_sale_amount=>-700, :adjust_trade_in_amount=>-350.0, :adjust_trade_low_amount=>-210.0, :options_dealer_retail_amount=>1200, :options_private_sale_amount=>1200, :options_trade_in_amount=>600.0, :options_trade_low_amount=>360.0, :adjusted_dealer_retail=>15500, :adjusted_private_sale=>13500, :adjusted_trade_in=>11250.0, :adjusted_trade_low=>10150.0})
    end

    it "Test deprication table -- With Option Codes and with Kilometer Adjustment" do
      y = Date.today - 9.years
      x = Glassguide::Vehicle.create(:code => "PLM12", :year => y.year, :mth => y.strftime("%b"), :price_dealer_retail => 15000, :price_private_sale => 13000, :price_trade_in => 11000, :price_trade_low => 10000 )
      expect(x.deprication_table(21000, true)).to eq({:price_dealer_retail=>15000, :price_private_sale=>13000, :price_trade_in=>11000, :price_trade_low=>10000, :adjust_dealer_retail_amount=>-900, :adjust_private_sale_amount=>-900, :adjust_trade_in_amount=>-450.0, :adjust_trade_low_amount=>-270.0, :options_dealer_retail_amount=>0, :options_private_sale_amount=>0, :options_trade_in_amount=>0.0, :options_trade_low_amount=>0.0, :adjusted_dealer_retail=>14100, :adjusted_private_sale=>12100, :adjusted_trade_in=>10550.0, :adjusted_trade_low=>9730.0})
    end

    it "Test deprication table -- With Option Codes and with Kilometer Adjustment" do
      y = Date.today - 9.years
      x = Glassguide::Vehicle.create(:code => "PLM12", :year => y.year, :mth => y.strftime("%b"), :price_dealer_retail => 15000, :price_private_sale => 13000, :price_trade_in => 11000, :price_trade_low => 10000 )
      expect(x.deprication_table).to eq({:price_dealer_retail=>15000, :price_private_sale=>13000, :price_trade_in=>11000, :price_trade_low=>10000, :adjust_dealer_retail_amount=>0, :adjust_private_sale_amount=>0, :adjust_trade_in_amount=>0, :adjust_trade_low_amount=>0, :options_dealer_retail_amount=>0, :options_private_sale_amount=>0, :options_trade_in_amount=>0.0, :options_trade_low_amount=>0.0, :adjusted_dealer_retail=>15000, :adjusted_private_sale=>13000, :adjusted_trade_in=>11000.0, :adjusted_trade_low=>10000.0})
    end

  end 
end