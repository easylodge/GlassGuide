module Glassguide
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Sets up the Glass Guide Configuration File"

      def copy_config
       template "glassguide_config.yml", "config/glassguide_config.yml"
      end
    
    end
  end
end