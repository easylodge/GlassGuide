require 'glassguide'
require 'fileutils'
require 'net/sftp'

namespace :glassguide do
  # task :import_all => :environment do #this needs to run with cron job once a month maby?
  #   Rake::Task['easylodge:glass:get_import_images'].invoke
  #   Rake::Task['easylodge:glass:get_data'].invoke
  #   Rake::Task['easylodge:glass:import_data'].invoke
  # end

  @login = YAML.load_file("#{Rails.root}/config/glassguide_config.yml")



  desc 'Runs both the glasses guide tasks(glassguide:get_import_images, glassguide:get_import_data) to update images and data'
  task :import_all => :environment do #this needs to run with cron job once a month maby?
    # Rake::Task['glassguide:get_import_images'].invoke <- disabled no images at this st
    Rake::Task['glassguide:get_import_data'].invoke
  end

  desc 'Downloads the most recent photo zip file, unzip and store on image save location'
  task :get_import_images => :environment do
    Net::SFTP.start(@login["glassguide_url"], @login["glassguide_photo_login"]["username"], password: @login["glassguide_photo_login"]["password"]) do |sftp|
      p "Logged in to #{@login['glassguide_url']}"
      filename = "Photo_" + Date.today.strftime("%b%y") + ".zip"
      
      begin
        # Check if file exists on SFTP server
        file_attrs = sftp.stat!(filename)
        p "Downloading #{filename} (#{file_attrs.size/1024}kb)"
        
        # Use non-blocking download with progress reporting
        local_path = "#{Rails.root}/#{filename}"
        sftp.download!(filename, local_path) do |event, downloader, *args|
          case event
          when :open then
            p "Starting download..."
          when :get then
            p "Downloaded #{args[1]} bytes" if args[1] % (1024 * 100) == 0  # Progress every 100KB
          when :close then
            p "Download completed"
          when :mkdir then
            p "Creating directory #{args[0]}"
          when :finish then
            p "Download finished"
          end
        end

        file_path = Pathname.new("#{Rails.root}/#{filename}")
        if file_path.exist?
          p "Download Succesful!"
          p "Unzipping #{filename}"
          %x{mkdir -p "#{Rails.root}/public/#{@login['image_directory']}"}
          %x{unzip -o "#{file_path}" -d "#{Rails.root}/public/#{@login['image_directory']}"}
          unzipped_folder = Pathname.new("#{Rails.root}/public/#{@login['image_directory']}")
          if unzipped_folder.exist?
            p "Unzip OK!"
            p "Save Succesful!"
            p "Removing downloaded zip file"
            %x{rm "#{file_path}"}
            p "All Done!"
          else
            p "Unzip Failed!"
          end
        else
          p "Download Failed!"
        end
      rescue Net::SFTP::StatusException => e
        if e.code == 2  # File not found
          p "#{filename} not found on SFTP server"
        else
          p "SFTP error: #{e.message}"
        end
      end
    end
    p "Closing SFTP connection"
  rescue Net::SSH::AuthenticationFailed => e
    p "SFTP login has failed: #{e.message}"
  rescue => e
    p "SFTP connection error: #{e.message}"
  end

  desc 'Downloads the most recent data zip files, unzip and merge'
  task :get_import_data => :environment do
    # download file from sftp server
    zip_file = Date.today.strftime("%b%y") + "eis.zip"
    zip_file_dest_folder = Pathname.new("#{Rails.root}/#{Date.today.strftime('%b%y') + "eis_#{@login['glassguide_photo_login']['username']}"}")
    
    sftp_request(
      @login["glassguide_url"], 
      @login["glassguide_photo_login"]["username"], 
      @login["glassguide_photo_login"]["password"], 
      zip_file, zip_file_dest_folder
    )
    
    Glassguide::Loader.new zip_file_dest_folder, true
    %x{rm -r "#{zip_file_dest_folder}"}
    puts 'Done!'
  end

  desc 'Import unzipped files from glass_temp directory for testing'
  task :import_unzipped_data => :environment do
    puts 'Looking for files in "app_root/glass_temp" directory'
    Glassguide::Loader.new "#{Rails.root}/glass_temp"
    puts 'Done!'
  end

  def sftp_request(url, username, password, filename, zip_file_dest_folder)
      Net::SFTP.start(url, username, password: password) do |sftp|
        p "Logged in to #{url} (#{username})"
        begin
          # Check if file exists on SFTP server
          file_attrs = sftp.stat!(filename)
          p "Downloading #{filename} (#{file_attrs.size/1024}kb)"
          
          # Use non-blocking download with progress reporting
          local_path = "#{Rails.root}/#{filename}"
          sftp.download!(filename, local_path) do |event, downloader, *args|
            case event
            when :open then
              p "Starting download..."
            when :get then
              p "Downloaded #{args[1]} bytes" if args[1] % (1024 * 100) == 0  # Progress every 100KB
            when :close then
              p "Download completed"
            when :mkdir then
              p "Creating directory #{args[0]}"
            when :finish then
              p "Download finished"
            end
          end

          zip_file_path = Pathname.new("#{Rails.root}/#{filename}")
          if zip_file_path.exist?
            p "Download OK!"

            p "Unzipping #{filename} to #{zip_file_dest_folder}"
            %x{unzip -o "#{zip_file_path}" -d "#{zip_file_dest_folder}"}
            unzipped_folder = Pathname.new(zip_file_dest_folder)

            if unzipped_folder.exist?
              p "Unzip OK!"
              p "Removing zip file #{filename}"
              %x{rm "#{filename}"}
            else
              p "Unzip Fail"
            end
          else
            p "Download Failed!"
          end
        rescue Net::SFTP::StatusException => e
          if e.code == 2  # File not found
            p "#{filename} not found on SFTP server"
          else
            p "SFTP error: #{e.message}"
          end
        end
      end
      p "Closing SFTP connection"
    rescue Net::SSH::AuthenticationFailed => e
      p "SFTP login has failed: #{e.message}"
    rescue => e
      p "SFTP connection error: #{e.message}"
    end

    def combine_files(first_folder_name, first_folder_path)
      current_folder = Date.today.strftime("%b%y") + "eis_#{@login["glassguide_extra_login"]['username']}"
      current_folder_path = Pathname.new("#{Rails.root}/#{current_folder}")

      if current_folder_path.exist? && first_folder_path
        p "copying #{current_folder_path} to #{first_folder_path}"
        %x{cp -a "#{current_folder_path}"/* "#{first_folder_path}"}

        p "Removing old folder #{current_folder}"
        %x{rm -rf "#{current_folder}"}
      else
        p "Could not find requested folder #{current_folder_path} or #{first_folder_path}"
      end
    
    end
end
