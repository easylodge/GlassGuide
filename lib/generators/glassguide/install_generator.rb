module Glassguide
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Sets up the Glass Guide Configuration File"

      def copy_config
       template "glassguide_config.yml", "config/glassguide_config.yml"
      end

      desc "Creates Glass Guide Migrations"
      
      def copy_migration
        template "migration_existing.rb", "db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_add_glassguide_tables.rb"
      end    

    end
  end
end