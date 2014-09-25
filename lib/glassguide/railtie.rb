require 'glassguide'
require 'rails'

module Glassguide  
  class Railtie < Rails::Railtie
    railtie_name :glassguide

    rake_tasks do
      load "tasks/glassguide.rake"
    end 
  end
end