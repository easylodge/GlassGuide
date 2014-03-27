require 'glassguide'
require 'fileutils'
require 'net/ftp'

namespace :glassguide do

  # task :import_all => :environment do #this needs to run with cron job once a month maby?
  #   Rake::Task['easylodge:glass:get_import_images'].invoke
  #   Rake::Task['easylodge:glass:get_data'].invoke
  #   Rake::Task['easylodge:glass:import_data'].invoke
  # end

  desc 'Runs both the glasses guide tasks(glassguide:get_import_images, glassguide:get_import_data) to update images and data'
  task :import_all => :environment do #this needs to run with cron job once a month maby?
    Rake::Task['glassguide:get_import_images'].invoke
    Rake::Task['glassguide:get_import_data'].invoke
  end



  desc 'Downloads the most recent photo zip file, unzip and store on image save location'
  task :get_import_images => :environment do
    glassguide_details = YAML.load_file("#{Rails.root}/config/glassguide_config.yml")
    

    ftp = Net::FTP.new(glassguide_details["glassguide_url"])
    glassguide_details["glassguide_login"].each do |glassguide_login|
      if ftp.login(glassguide_login["username"],glassguide_login["password"])
        p "Logged in to #{glassguide_details['glassguide_url']}"
        filename = "Photo_" + Date.today.strftime("%b%y") + ".zip"
        remote_file = ftp.nlst.reject{|r| r != filename}.first
        if remote_file
          p "Downloading #{filename} (#{remote_file.size*1024}kb)"
          ftp.getbinaryfile(filename)

          file_path = Pathname.new("#{Rails.root}/#{filename}")
          if file_path.exist?
            p "Download Succesful!"

            p "Unzipping #{filename}"

            %x{mkdir -p "#{Rails.root}/#{glassguide_details['image_directory']}"}
            %x{unzip "#{file_path}" -d "#{Rails.root}/#{glassguide_details['image_directory']}"}
            unzipped_folder = Pathname.new("#{Rails.root}/#{glassguide_details['image_directory']}")
            if unzipped_folder.exist?
              p "Unzip OK!"
              p "Save Succesful!"

              p "Removing downloaded zip file"
              %x{rm "#{filename}"}
              p "All Done!"
            else
              p "Unzip Fail"
            end
          else
            p "Download Failed!"
          end
        else
          p "#{filename} not found on ftp server"
        end
      else
        p "Ftp login has failed"
      end
    end
  end

  desc 'Downloads the most recent data zip files, unzip and merge'
  task :get_import_data => :environment do
    glassguide_details = YAML.load_file("#{Rails.root}/config/glassguide_config.yml")

    # downloading required files
    glassguide_details["glassguide_login"].each do |glassguide_login|
      ftp = Net::FTP.new(glassguide_details["glassguide_url"])
      if ftp.login(glassguide_login["username"],glassguide_login["password"])
        p "Logged in to ftp.glassguide.com.au (#{glassguide_login['username']})"
        filename = Date.today.strftime("%b%y") + "eis.zip"
        remote_file = ftp.nlst.reject{|r| r != filename}.first
        if remote_file
          p "Downloading #{filename} (#{remote_file.size*1024}kb)"
          ftp.getbinaryfile(filename)

          zip_file_path = Pathname.new("#{Rails.root}/#{filename}")
          if zip_file_path.exist?
            p "Download OK!"

            p "Unzipping #{filename} to #{filename.split('.').first}_#{glassguide_login['username']}"
            %x{unzip "#{zip_file_path}" -d "#{filename.split('.').first}_#{glassguide_login['username']}"}
            unzipped_folder = Pathname.new("#{Rails.root}/#{filename.split('.').first}_#{glassguide_login['username']}/")

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
        else
          p "#{filename} not found on ftp server"
        end
      else
        p "Ftp login has failed"
      end

      ftp.close
      p "Closing connection ftp.glassguide.com.au (#{glassguide_login['username']})"
    end

    # merging downloaded files
    first_folder_name = Date.today.strftime('%b%y') + "eis_#{glassguide_details['glassguide_login'].first['username']}"
    first_folder_path = Pathname.new("#{Rails.root}/#{first_folder_name}")

    p "Combining files"
    glassguide_details["glassguide_login"].each_with_index do |glassguide_login,index|
      unless index == 0 # copy all files to folder #1
        current_folder = Date.today.strftime("%b%y") + "eis_#{glassguide_login['username']}"
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

    p "Zipping combined folder #{first_folder_name}"
    %x{cd "#{first_folder_path}" && zip -r "#{Rails.root}/#{Date.today.strftime('%b%y')}"eis.zip .} #zipping the folder aswell as the files, only want to zip the folder content

    p "Removing combined folder #{first_folder_name}"
    %x{rm -rf "#{first_folder_name}"}

    ENV['FILENAME'] = "#{Rails.root}/#{Date.today.strftime('%b%y')}eis.zip"
    

    
    gp = Object.new.send :extend, Glassguide::Package

    puts 'Extracting zip'
    extracted_zip = gp.extract_zip_to_tempdir ENV['FILENAME']
    Glassguide::Loader.new extracted_zip, true

    %x{rm "#{ENV['FILENAME']}"}
    puts 'Done!'
  end
end
