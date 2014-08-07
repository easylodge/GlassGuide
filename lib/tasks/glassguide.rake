require 'glassguide'
require 'fileutils'
require 'net/ftp'

namespace :glassguide do
  # task :import_all => :environment do #this needs to run with cron job once a month maby?
  #   Rake::Task['easylodge:glass:get_import_images'].invoke
  #   Rake::Task['easylodge:glass:get_data'].invoke
  #   Rake::Task['easylodge:glass:import_data'].invoke
  # end

  @login = YAML.load_file("#{Rails.root}/config/glassguide_config.yml")



  desc 'Runs both the glasses guide tasks(glassguide:get_import_images, glassguide:get_import_data) to update images and data'
  task :import_all => :environment do #this needs to run with cron job once a month maby?
    Rake::Task['glassguide:get_import_images'].invoke
    Rake::Task['glassguide:get_import_data'].invoke
  end

  desc 'Downloads the most recent photo zip file, unzip and store on image save location'
  task :get_import_images => :environment do
    
    ftp = Net::FTP.new(@login["glassguide_url"])
    ftp.passive=true
    
    if ftp.login(@login["glassguide_photo_login"]["username"],@login["glassguide_photo_login"]["password"])
      p "Logged in to #{@login['glassguide_url']}"
      filename = "Photo_" + Date.today.strftime("%b%y") + ".zip"
      remote_file = ftp.nlst.reject{|r| r != filename}.first
      if remote_file
        p "Downloading #{filename} (#{remote_file.size*1024}kb)"
        ftp.getbinaryfile(filename)

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
      else
        p "#{filename} not found on ftp server"
      end
    else
      p "FTP login has failed!"
    end
    ftp.close
    p "Closing FTP connection"
  end

  desc 'Downloads the most recent data zip files, unzip and merge'
  task :get_import_data => :environment do
    
    # downloading required files
    ftp_request(@login["glassguide_url"], @login["glassguide_photo_login"]["username"], @login["glassguide_photo_login"]["password"])
    ftp_request(@login["glassguide_url"], @login["glassguide_extra_login"]["username"], @login["glassguide_extra_login"]["password"])

    # merging downloaded files
    first_folder_name = Date.today.strftime('%b%y') + "eis_#{@login['glassguide_photo_login']['username']}"
    first_folder_path = Pathname.new("#{Rails.root}/#{first_folder_name}")

    p "Combining files"
    combine_files(first_folder_name, first_folder_path)    

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

  def ftp_request(url, username, password)
      ftp = Net::FTP.new(url)
      ftp.passive=true
      if ftp.login(username, password)
        p "Logged in to ftp.glassguide.com.au (#{username})"
        filename = Date.today.strftime("%b%y") + "eis.zip"
        remote_file = ftp.nlst.reject{|r| r != filename}.first
        if remote_file
          p "Downloading #{filename} (#{remote_file.size*1024}kb)"
          ftp.getbinaryfile(filename)

          zip_file_path = Pathname.new("#{Rails.root}/#{filename}")
          if zip_file_path.exist?
            p "Download OK!"

            p "Unzipping #{filename} to #{filename.split('.').first}_#{username}"
            %x{unzip "#{zip_file_path}" -d "#{filename.split('.').first}_#{username}"}
            unzipped_folder = Pathname.new("#{Rails.root}/#{filename.split('.').first}_#{username}/")

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
      p "Closing FTP connection"
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
