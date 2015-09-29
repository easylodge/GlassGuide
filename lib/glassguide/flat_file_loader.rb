# encoding: utf-8
['pathname', 'zip'].each {|x| require x}
module Glassguide
  module Package
    UUIDchars = ("a".."f").to_a + ("0".."9").to_a
    def uuid_seg(len)
      ret = ""
      1.upto(len) { |i| ret << UUIDchars[rand(UUIDchars.size-1)] }; ret
    end

    def random_uuid
      "#{uuid_seg(8)}-#{uuid_seg(4)}-#{uuid_seg(4)}-#{uuid_seg(4)}-#{uuid_seg(12)}"
    end

    def extract_zip_to_tempdir(zip_path)
      temp_root = Pathname.new((ENV['TEMP'] || ENV['TMP'] || '/tmp'))
      raise "Can’t find a temp directory" unless temp_root.exist?

      # Figure out our temp directory
      temp_dir = nil
      while (temp_dir = temp_root.join(random_uuid())).exist?
        nil
      end
      temp_dir.mkpath

      Zip::File.open(zip_path) do |zf|
        zf.each do |e|
          if (m = /^(.*)[\\\/][^\\\/]*$/.match(e.name))
            temp_dir.join(m[1]).mkpath
          end
          zf.extract(e.name, File.join(temp_dir.to_s, e.name))
        end
      end

      temp_dir.to_s
    end
  end

  class Loader
    include Glassguide::Package

    GLASS_KILOMETRES         = Glassguide::Kilometer.dup
    GLASS_KILOMETRES_VEHICLE = Glassguide::KilometerVehicle.dup
    GLASS_OPTION_VALUE       = Glassguide::OptionValue.dup
    GLASS_OPTION             = Glassguide::Option.dup
    GLASS_OPTION_DETAIL      = Glassguide::OptionDetail.dup
    GLASS_VEHICLE            = Glassguide::Vehicle.dup

    GLASS_TEMP_MODELS = [GLASS_KILOMETRES, GLASS_KILOMETRES_VEHICLE, GLASS_OPTION_VALUE, GLASS_OPTION, GLASS_OPTION_DETAIL, GLASS_VEHICLE]

    attr_accessor :log

    def append_log(message)
      message = "#{@filename}: #{message}"
      self.log << message
      puts message
    end

    def initialize(extracted_zip, verbose = false)
      @verbose = verbose
      self.log = []

      setup_temporary_tables
      process_extracted_files(extracted_zip)
      rename_temporary_tables
    ensure
      restore_model_table_names
    end

    def setup_temporary_tables
      ActiveRecord::Base.transaction do
        GLASS_TEMP_MODELS.each do |klass|
          raise if klass.table_name =~ /^temporary_/

          orig_table_name = klass.table_name
          temp_table_name = temp_table_name(orig_table_name)
          # orig_index_count = ActiveRecord::Base.connection.execute("\\d #{orig_table_name}").to_a.count

          ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS #{temp_table_name}"

          # Create temporary table with same structure and indexes (but no data)
          ActiveRecord::Base.connection.execute "CREATE TABLE #{temp_table_name} (LIKE #{orig_table_name})"
          # ActiveRecord::Base.connection.execute "INSERT #{temp_table_name} SELECT * FROM #{orig_table_name} WHERE 0"
          # temp_index_count = ActiveRecord::Base.connection.execute("SHOW INDEXES FROM #{temp_table_name}").to_a.count

          # unless orig_index_count == temp_index_count
            # raise "Index count mismatch between #{orig_table_name} and #{temp_table_name}"
          # end

          klass.table_name = temp_table_name
        end
      end
    end

    def process_extracted_files(extracted_zip)
      extracted_files   = Dir.glob("#{extracted_zip}/*")
      new_vehicle_files = extracted_files.select { |file| File.extname(file) == '.N12' }
      extracted_files   = extracted_files - new_vehicle_files

      extracted_files.each do |file|
        case File.extname(file)
        when ".TRN" #transmission types
        when ".MAK" #makes
        when ".ENG" #engine types
        when ".BDY" #body types
        when ".REC" #glasses guide code changes

        when ".KMS" #km, category, over/under, up to kms, adjust, amount
          import_file file, GLASS_KILOMETRES, :find_or_create, [:km_category, :over_under, :up_to_kms],
            :rename_fields => {
              :"km_category" => :km_category,
              :"over/under" => :over_under,
              :uptokms => :up_to_kms,
            }

        when ".KAT" #glass's code, km category, average kms, nvic
          import_file file, GLASS_KILOMETRES_VEHICLE, :find_or_create, [:nvic],
            :rename_fields => {
              :"glass's_code" => :code,
              :"average_kms" => :average_kilometers_in_thousands,
            }

        when ".UOP" #make, model ,family ,option ,years ,old(in years), adjust, amount
          import_file file, GLASS_OPTION_VALUE, :find_or_create, [:option, :years_old]

        when ".OPT" #glass's code, rec type, feature and option codes, nvic
          import_file file, GLASS_OPTION, :find_or_create, [:vehicle_code, :rec_type],
            :rename_fields => {
              :"glass's_code" => :vehicle_code,
              :"feature_&_option_codes" => :option_codes,
            }

        when ".OCD" #code, extras
          import_file file, GLASS_OPTION_DETAIL, :find_or_create, [:code]

        when ".U12" #(older vehilces from 1960) code, month, make, family, variant, series, style, engine type, engine cc, engine size, transmission, cylinder, $$$, $$, vehicle width, $, nvic, year, bt, et, tt
          import_file file, GLASS_VEHICLE, :find_or_create, [:nvic],
            :rename_fields => {
              :"$" => :'price_trade_low',
              :"$$" => :'price_trade_in',
              :"$$$" => :'price_dealer_retail',
              :"cyl." => :cyl,
              :code => :code, # Get around the no mass assignment on primary key issue

              # old car database
              :'b/av.' => :'price_trade_low',
              :'av.' => :'price_trade_in',
              :'a/av.' => :'price_dealer_retail',

              # motorcycle database
              :new_pr => :price_new,
              :trade_low => :price_trade_low,
              :trade => :price_trade_in,
              :retail => :price_dealer_retail,
            
             # imported database
              :model => :family,
              :engine_type => :engine,
            }

        when ".U22" #imported
          import_file file, GLASS_VEHICLE, :find_or_create, [:nvic],
            :rename_fields => {
              :"$" => :'price_trade_low',
              :"$$" => :'price_trade_in',
              :"$$$" => :'price_dealer_retail',
              :"cyl." => :cyl,
              :code => :code, # Get around the no mass assignment on primary key issue
            }
        end
      end

      # Process the new vehicle files last, these vehicles should already exist
      # in the system.
      new_vehicle_files.each do |file|
        raise unless File.extname(file) == '.N12' #(new vehicle prices) code, month, make, family, variant, series, style, engine type, engine cc, engine size, transmission, cylinder, new price, vehicle width, nvic, year, bt, et, tt

        import_file file, GLASS_VEHICLE, :update, [:nvic],
          :rename_fields => {
            :new_pr => :'price_new',
            :"cyl." => :cyl,
            :code => :code, # Get around the no mass assignment on primary key issue
          }
      end
    end

    def rename_temporary_tables
      ActiveRecord::Base.transaction do
        GLASS_TEMP_MODELS.each do |klass|
          raise unless klass.table_name =~ /^temporary_/

          temp_table_name = klass.table_name
          orig_table_name = temp_table_name.gsub('temporary_', '')

          ActiveRecord::Base.connection.execute "DROP TABLE #{orig_table_name}"
          ActiveRecord::Base.connection.execute "ALTER TABLE #{temp_table_name} RENAME TO #{orig_table_name}"
        end
      end
    end

    def restore_model_table_names
      ActiveRecord::Base.transaction do
        GLASS_TEMP_MODELS.each do |klass|
          orig_table_name = klass.table_name.gsub('temporary_', '')
          klass.table_name = orig_table_name
        end
      end
    end

    def import_file(file, klass, action, keys, options = {})
      motorcycle = file.split('/').last[/^MCG/].present?
      imported = file.split('/').last[/^IMP/].present?

      progress = 0
      total_lines = `wc -l < #{Shellwords.escape file}`.strip.to_i

      parse_file(file, options).each_slice 1000 do |rows|
        progress += 1000
        p "#{progress} / #{total_lines}"
        klass.transaction do
          rows.each do |row|
            case action
            when :find_or_create
              # set year to current year if nil
              row[:year] = DateTime.now.year.to_s if (!row.has_key?(:year) && (klass == GLASS_VEHICLE))
              row[:mth] =  DateTime.now.strftime("%b") if (!row.has_key?(:mth) && (klass == GLASS_VEHICLE))
              row[:imported] =  imported if (klass == GLASS_VEHICLE)
              # these are all used vehicles, set price_new to nil
              row[:price_new] = nil if row.has_key?(:price_new)
              row[:motorcycle] = motorcycle if (klass == GLASS_VEHICLE)
              row[:price_private_sale] = ((row[:price_dealer_retail].to_i - row[:price_trade_in].to_i) / 2) + row[:price_trade_in].to_i if row.has_key?(:price_dealer_retail)
              klass.find_or_create_by row
            when :update
              # updates only on new vehicles
              #filter by keys
              tmp_row = row.select{|k,v| keys.include? k}
              record = klass.find_by tmp_row
              record.update_attributes! row
            else
              raise "Invalid action: #{action}"
            end
          end
        end
      end
    end

    def parse_file(file, options = {}, &block)
      unless block_given?
        return self.enum_for(:parse_file, file, options)
      end

      @filename = File.basename(file)
      options = {
        :rename_fields => {},
        :lines => 0,
        :after => {}
      }.update(options)

      fields = []
      field_pattern = ""
      field_names = ""
      current_line = 0

      File.foreach(file) do |line|
        current_line += 1

        # Get field sizes
        if current_line == 1
          field_names = line

        elsif current_line == 2
          chr_ids = line.gsub(/([ ]+)/," ").split(/([^0-9]+)/).collect(&:to_i).reject(&:zero?)
          chr_ids << line.size

          chr_ids.each_with_index do |ci, index|
            segment = ci.to_i - chr_ids[index+1] unless chr_ids[index+1].nil?
            if segment
              fields << segment.abs
            end
          end
          field_pattern = "A#{fields.join('A')}"
          field_names = field_names.unpack(field_pattern).collect(&:dash_blank!).collect{ |field| field.strip.gsub(/ /, "_") }.collect(&[:strip, :downcase, :to_sym])
          field_names.collect! do |field|
            options[:rename_fields][field].nil? ? field : options[:rename_fields][field]
          end
        end

        # Next lines contain data
        start_line = 3
        if current_line > start_line
          return if current_line < start_line + options[:lines] && options[:lines] > 0

          row_hash = {}
          row = line.unpack(field_pattern)
          row.collect!(&[:dash_blank!, :strip])

          field_names.each_with_index do |field, index|
            row[index] = "(No #{field.to_s})" if row[index].to_s.strip == "-"
            if options[:after][field.to_sym]
              row[index].send(options[:after][field.to_sym])
            end
            row_hash.merge!(field => row[index].to_s.strip) unless field == :-
          end

          yield row_hash if block_given?
        end
        # progress_bar.inc if @verbose
      end
      # progress_bar.finish if @verbose
    rescue => e
      append_log "Error: #{e.message}\n\t#{e.backtrace.join "\n\t"}"
    end

    def temp_table_name(table_name)
      "temporary_#{table_name}"
    end
  end

  class Images
    include Glassguide::Package
    attr_accessor :log
  end
end
