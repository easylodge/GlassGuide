require "digest"
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
          
          # Copy indexes from original table to temporary table
          if klass == GLASS_VEHICLE
            # Drop index if it exists, then create it
            ActiveRecord::Base.connection.execute "DROP INDEX IF EXISTS index_#{temp_table_name}_on_crc_hash"
            ActiveRecord::Base.connection.execute "CREATE UNIQUE INDEX index_#{temp_table_name}_on_crc_hash ON #{temp_table_name} (crc_hash)"
          end

          if klass == GLASS_OPTION 
            # Drop index if it exists, then create it
            ActiveRecord::Base.connection.execute "DROP INDEX IF EXISTS index_#{temp_table_name}_on_crc_hash"
            ActiveRecord::Base.connection.execute "CREATE UNIQUE INDEX index_#{temp_table_name}_on_crc_hash ON #{temp_table_name} (crc_hash)"
          end

          if klass == GLASS_OPTION_DETAIL
            # Drop index if it exists, then create it
            ActiveRecord::Base.connection.execute "DROP INDEX IF EXISTS index_#{temp_table_name}_on_crc_hash"
            ActiveRecord::Base.connection.execute "CREATE UNIQUE INDEX index_#{temp_table_name}_on_crc_hash ON #{temp_table_name} (crc_hash)"
          end 

          if klass == GLASS_KILOMETRES 
            # Drop index if it exists, then create it
            ActiveRecord::Base.connection.execute "DROP INDEX IF EXISTS index_#{temp_table_name}_on_crc_hash"
            ActiveRecord::Base.connection.execute "CREATE UNIQUE INDEX index_#{temp_table_name}_on_crc_hash ON #{temp_table_name} (crc_hash)" 
          end

          if klass == GLASS_KILOMETRES_VEHICLE
            # Drop index if it exists, then create it
            ActiveRecord::Base.connection.execute "DROP INDEX IF EXISTS index_#{temp_table_name}_on_crc_hash"
            ActiveRecord::Base.connection.execute "CREATE UNIQUE INDEX index_#{temp_table_name}_on_crc_hash ON #{temp_table_name} (crc_hash)" 
          end 
          
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
      truck = file.split('/').last[/^HCV/].present?
      imported = file.split('/').last[/^IMP/].present?

      progress = 0
      total_lines = `wc -l < #{Shellwords.escape file}`.strip.to_i

      parse_file(file, klass, options) do |data_rows|
        data_rows.each_slice(1_000) do |rows|
          progress += 1_000
          p "#{progress} / #{total_lines}"
          p "writing... #{klass.name}"
          klass.upsert_all(rows, unique_by: [:crc_hash])
        end
      end
    end

    def parse_file(file, klass, options = {})
      lines = File.readlines(file, chomp: true)

      header_line = lines[0]
      index_line  = lines[1]
      separator   = lines[2]
      data_lines  = lines[3..]

      # Get column positions from index line
      positions = index_line.scan(/\d+/).map(&:to_i)

      # Build column ranges
      ranges = positions.each_cons(2).map { |a, b| (a - 1)...(b - 1) }
      ranges << ((positions.last - 1)..-1)

      # Extract headers using the same ranges
      headers = ranges.map { |range| header_line[range].to_s.strip }

      motorcycle = file.split('/').last[/^MCG/].present?
      truck = file.split('/').last[/^HCV/].present?
      imported = file.split('/').last[/^IMP/].present?

      valid_columns = klass.column_names.map(&:to_sym)

      parsed_data = data_lines.map do |line|
        row = {}
        headers.each_with_index do |header, i|
          raw = line[ranges[i]] || ""
          key = header.downcase.gsub(" ", "_").to_sym
          # so we only store support column keys
          if options&.dig(:rename_fields, key)
            row[options[:rename_fields][key]] = raw.strip.empty? ? "-" : raw.strip
          end
          if valid_columns.include?(key) && key.present?
            row[key] = raw.strip.empty? ? "-" : raw.strip
          end
        end

        row[:price_new] = nil if row.has_key?(:price_new)
        if klass == GLASS_VEHICLE
          row[:year] = row.has_key?(:year) ? row[:year] : DateTime.now.year.to_s
          row[:mth] = row.has_key?(:mth) ? row[:mth] : DateTime.now.strftime("%b")
          row[:imported] =  imported
          row[:vehicle_type] = 'car'
          row[:vehicle_type] = 'motorcycle' if motorcycle
          row[:vehicle_type] = 'truck' if truck
        end
        # signatur per object
        row[:crc_hash] = Digest::MD5.hexdigest(row.to_json)
        row
      end

      yield parsed_data if block_given?
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
