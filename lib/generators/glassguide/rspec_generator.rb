module Glassguide
  module Generators
    class RspecGenerator < Rails::Generators::Base
      
      source_root File.expand_path("../../templates", __FILE__)
      desc "Sets up the Glass Guide Rspec files"

      def copy_rspec
        template "glassguide_spec.rb", "spec/models/glassguide_spec.rb"
      end
    
    end
  end
end