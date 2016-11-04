# Glassguide

Glass' guide gem for EasyLodge

## Installation

Add this line to your application's Gemfile:

    gem 'glassguide'

And then execute:

    $ bundle

Then run install generator:

    rails g glassguide:install

You can also copy the gem rspec tests to your local app with:

    rails g glassguide:rspec

Then run migrations:

    rake db:migrate

Fill in Glass Guide details in config/glassguide_config.yml

Then run rake tasks to import db records and photos

    rake glassguide:get_import_data (downloads, unzips and import all the glassguide records and overwrite existing records)
    rake glassguide:get_import_images (downloads, unzips and import newest images - will overwrite existing)

  or both:

    rake glassguide:import_all (do both)

  or:

    rake glassguide:import_unzipped_data (import unzipped files from the app_root/glass_temp directory - for importing selected files)  

## Usage

  After the import you have the glass guide records.

### Glassguide::Vehicle

####Available scopes:

    .cars_only
    .motorcycles_only
    .trucks_only
    .imported_only
    .select_year(year)
    .select_make(make)
    .select_families(family)
    .select_variants(variant)
    .select_styles(style)
    .select_transmission(transmission)
    .select_series(series)
    .select_engines(engine)
    .select_vehicle_type(choice)

####Scopes that return array of available values:

    .list_year
    .list_make
    .list_families
    .list_variants
    .list_styles
    .list_transmission
    .list_series
    .list_engines

####Instance Variables:

    .photo
    .years_old
    .retail_price

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
