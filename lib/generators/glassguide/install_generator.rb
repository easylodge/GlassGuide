module Glassguide
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      
      source_root File.expand_path("../../templates", __FILE__)
      desc "Sets up the Glass Guide Configuration File"

      def copy_config
        template "glassguide_config.yml", "config/glassguide_config.yml"
      end

      def copy_array_extension
        template "array_extensions.rb", "config/initializers/array_extensions.rb"
      end
      
      def self.next_migration_number(dirname)
        if ActiveRecord::Base.timestamped_migrations
          Time.new.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end
      
      def create_migration_file
        #copy migration
        migration_template "migration_glassguide_kilometers.rb", "db/migrate/create_glassguide_kilometers.rb"
        sleep 1
        migration_template "migration_glassguide_kilometer_vehicles.rb", "db/migrate/create_glassguide_kilometer_vehicles.rb"
        sleep 1
        migration_template "migration_glassguide_option_values.rb", "db/migrate/create_glassguide_option_values.rb"
        sleep 1
        migration_template "migration_glassguide_options.rb", "db/migrate/create_glassguide_options.rb"
        sleep 1
        migration_template "migration_glassguide_option_details.rb", "db/migrate/create_glassguide_option_details.rb"
        sleep 1
        migration_template "migration_glassguide_vehicles.rb", "db/migrate/create_glassguide_vehicles.rb"
      end
    end
  end
end