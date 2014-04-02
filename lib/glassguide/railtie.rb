require 'glassguide'
require 'rails'

module RakeTasks
  class Railtie < Rails::Railtie
    railtie_name :glassguide

    rake_tasks do
      load "tasks/glassguide.rake"
    end 
  end
end